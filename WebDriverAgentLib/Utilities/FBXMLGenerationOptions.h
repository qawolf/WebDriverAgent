/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBXMLGenerationOptions : NSObject

/**
 XML buidling scope. Passing nil means the XML should be built in the default scope,
 i.e no changes to the original tree structore. If the scope is provided then the resulting
 XML tree will be put under the root, which name is equal to the given scope value.
 */
@property (nonatomic, nullable) NSString *scope;
/**
 The list of attribute names to exclude from the resulting document.
 Passing nil means all the available attributes should be included
 */
@property (nonatomic, nullable) NSArray<NSString *> *excludedAttributes;

/**
 Whether to pre-warm the snapshot's visibility cache before XML generation.

 When non-nil and truthy, the XML generator performs a post-order walk of the
 snapshot tree and resolves each node's `visible` attribute before producing
 the XML. This populates the snapshot's `additionalAttributes` cache so that
 the descendant-visibility short-circuit in `fb_hasVisibleDescendants` (the
 "Tier B" heuristic) actually fires for parent nodes, instead of always
 falling through to the expensive synchronous AX-framework IPC.

 Nil means "no warming" (default behaviour). A tri-state NSNumber is used so
 that callers may explicitly disable warming (@NO) and future versions can
 layer in a session-wide fallback without changing the API.
 */
@property (nonatomic, nullable) NSNumber *warmVisibilityCache;

/**
 Allows to provide XML scope.

 @param scope See the property description above
 @return self instance for chaining
 */
- (FBXMLGenerationOptions *)withScope:(nullable NSString *)scope;

/**
 Allows to provide a list of excluded XML attributes.

 @param excludedAttributes See the property description above
 @return self instance for chaining
 */
- (FBXMLGenerationOptions *)withExcludedAttributes:(nullable NSArray<NSString *> *)excludedAttributes;

/**
 Allows to opt in to (or out of) the visibility-cache pre-warm pass.

 @param warmVisibilityCache See the property description above
 @return self instance for chaining
 */
- (FBXMLGenerationOptions *)withWarmVisibilityCache:(nullable NSNumber *)warmVisibilityCache;

@end

NS_ASSUME_NONNULL_END
