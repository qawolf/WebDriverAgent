/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "XCUIElement+FBIsVisible.h"

#import <stdatomic.h>

#import "FBElementUtils.h"
#import "FBLogger.h"
#import "FBXCodeCompatibility.h"
#import "FBXCElementSnapshotWrapper+Helpers.h"
#import "XCUIElement+FBUtilities.h"
#import "XCUIElement+FBVisibleFrame.h"
#import "XCTestPrivateSymbols.h"

NSNumber* _Nullable fetchSnapshotVisibility(id<FBXCElementSnapshot> snapshot)
{
  return nil == snapshot.additionalAttributes ? nil : snapshot.additionalAttributes[FB_XCAXAIsVisibleAttribute];
}

@implementation XCUIElement (FBIsVisible)

- (BOOL)fb_isVisible
{
  @autoreleasepool {
    id<FBXCElementSnapshot> snapshot = [self fb_standardSnapshot];
    return [FBXCElementSnapshotWrapper ensureWrapped:snapshot].fb_isVisible;
  }
}

@end

@implementation FBXCElementSnapshotWrapper (FBIsVisible)

- (BOOL)fb_hasVisibleDescendants
{
  // Instrument the descendant-cache short-circuit so we can measure how often
  // it fires vs falls through to the synchronous AX-framework IPC. Counters
  // are process-wide and accumulate across requests; this is intentional —
  // the rate (hits/calls) is the useful signal, not the absolute totals.
  // Logging every 50 calls keeps the output tractable on dense screens
  // (500+ nodes per /source).
  static _Atomic NSUInteger fbVisCacheCalls = 0;
  static _Atomic NSUInteger fbVisCacheHits = 0;

  NSUInteger descendantsWalked = 0;
  BOOL hit = NO;
  for (id<FBXCElementSnapshot> descendant in (self._allDescendants ?: @[])) {
    descendantsWalked++;
    if ([fetchSnapshotVisibility(descendant) boolValue]) {
      hit = YES;
      break;
    }
  }

  NSUInteger calls = atomic_fetch_add(&fbVisCacheCalls, 1) + 1;
  if (hit) {
    atomic_fetch_add(&fbVisCacheHits, 1);
  }
  if (0 == (calls % 50)) {
    NSUInteger hits = atomic_load(&fbVisCacheHits);
    double hitRate = 100.0 * (double)hits / (double)calls;
    [FBLogger logFmt:@"[QA_WOLF] [INFO] [VisCache] descendant-cache stats: calls=%lu hits=%lu (%.1f%%) lastWalked=%lu lastResult=%@",
     (unsigned long)calls,
     (unsigned long)hits,
     hitRate,
     (unsigned long)descendantsWalked,
     hit ? @"YES" : @"NO"];
  }
  return hit;
}

- (BOOL)fb_isVisible
{
  NSNumber *isVisible = fetchSnapshotVisibility(self);
  if (nil != isVisible) {
    return isVisible.boolValue;
  }

  // Fetching the attribute value is expensive.
  // Shortcircuit here to save time and assume if any of descendants
  // is already determined as visible then the container should be visible as well
  if ([self fb_hasVisibleDescendants]) {
    return YES;
  }

  NSError *error;
  NSNumber *attributeValue = [self fb_attributeValue:FB_XCAXAIsVisibleAttributeName
                                               error:&error];
  if (nil != attributeValue) {
    NSMutableDictionary *updatedValue = [NSMutableDictionary dictionaryWithDictionary:self.additionalAttributes ?: @{}];
    [updatedValue setObject:attributeValue forKey:FB_XCAXAIsVisibleAttribute];
    self.snapshot.additionalAttributes = updatedValue.copy;
    @autoreleasepool {
      return [attributeValue boolValue];
    }
  }

  NSLog(@"Cannot determine visiblity of %@ natively: %@. Defaulting to: %@",
        self.fb_description, error.description, @(NO));
  return NO;
}

@end
