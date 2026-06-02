/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "FBDebugCommands.h"

#import "FBRouteRequest.h"
#import "FBSession.h"
#import "FBXMLGenerationOptions.h"
#import "XCUIApplication+FBHelpers.h"
#import "XCUIElement+FBUtilities.h"
#import "FBXPath.h"

@implementation FBDebugCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/source"] respondWithTarget:self action:@selector(handleGetSourceCommand:)],
    [[FBRoute GET:@"/source"].withoutSession respondWithTarget:self action:@selector(handleGetSourceCommand:)],
    [[FBRoute GET:@"/wda/accessibleSource"] respondWithTarget:self action:@selector(handleGetAccessibleSourceCommand:)],
    [[FBRoute GET:@"/wda/accessibleSource"].withoutSession respondWithTarget:self action:@selector(handleGetAccessibleSourceCommand:)],
  ];
}


#pragma mark - Commands

static NSString *const SOURCE_FORMAT_XML = @"xml";
static NSString *const SOURCE_FORMAT_JSON = @"json";
static NSString *const SOURCE_FORMAT_DESCRIPTION = @"description";

+ (id<FBResponsePayload>)handleGetSourceCommand:(FBRouteRequest *)request
{
  // This method might be called without session
  XCUIApplication *application = request.session.activeApplication ?: XCUIApplication.fb_activeApplication;
  NSString *sourceType = request.parameters[@"format"] ?: SOURCE_FORMAT_XML;
  NSString *sourceScope = request.parameters[@"scope"];
  id result;
  if ([sourceType caseInsensitiveCompare:SOURCE_FORMAT_XML] == NSOrderedSame) {
    NSArray<NSString *> *excludedAttributes = nil == request.parameters[@"excluded_attributes"]
      ? nil
      : [request.parameters[@"excluded_attributes"] componentsSeparatedByString:@","];
    // PoC (poc/warm-visibility-cache): `warm_visibility_cache` querystring as a
    // tri-state NSNumber. Default is @YES (warming ON) so /source always
    // pre-warms the visibility cache without needing the querystring; callers
    // can still explicitly opt out with warm_visibility_cache=false|0|no.
    // Forwarded to FBXMLGenerationOptions so FBXPath performs the pre-warm pass.
    NSString *warmParam = request.parameters[@"warm_visibility_cache"];
    NSNumber *warmVisibilityCache = @YES;
    if (nil != warmParam) {
      NSString *normalized = [warmParam lowercaseString];
      warmVisibilityCache = ([normalized isEqualToString:@"true"]
                             || [normalized isEqualToString:@"1"]
                             || [normalized isEqualToString:@"yes"])
        ? @YES
        : @NO;
    }
    result = [application fb_xmlRepresentationWithOptions:
        [[[[FBXMLGenerationOptions new]
           withExcludedAttributes:excludedAttributes]
          withWarmVisibilityCache:warmVisibilityCache]
         withScope:sourceScope]];
  } else if ([sourceType caseInsensitiveCompare:SOURCE_FORMAT_JSON] == NSOrderedSame) {
    NSString *excludedAttributesString = request.parameters[@"excluded_attributes"];
    NSSet<NSString *> *excludedAttributes = (excludedAttributesString == nil)
          ? nil
          : [NSSet setWithArray:[excludedAttributesString componentsSeparatedByString:@","]];

    result = [application fb_tree:excludedAttributes];
  } else if ([sourceType caseInsensitiveCompare:SOURCE_FORMAT_DESCRIPTION] == NSOrderedSame) {
    result = application.fb_descriptionRepresentation;
  } else {
    return FBResponseWithStatus([FBCommandStatus invalidArgumentErrorWithMessage:[NSString stringWithFormat:@"Unknown source format '%@'. Only %@ source formats are supported.",
                                                                                  sourceType, @[SOURCE_FORMAT_XML, SOURCE_FORMAT_JSON, SOURCE_FORMAT_DESCRIPTION]] traceback:nil]);
  }
  if (nil == result) {
    return FBResponseWithUnknownErrorFormat(@"Cannot get '%@' source of the current application", sourceType);
  }
  return FBResponseWithObject(result);
}

+ (id<FBResponsePayload>)handleGetAccessibleSourceCommand:(FBRouteRequest *)request
{
  // This method might be called without session
  XCUIApplication *application = request.session.activeApplication ?: XCUIApplication.fb_activeApplication;
  return FBResponseWithObject(application.fb_accessibilityTree ?: @{});
}

@end
