//
//  QAWSnapshot.m
//  ios-agent
//
//  Created by Elton Carreiro on 04/09/25.
//

#import "XCUIElement+FBUtilities.h"
#import "QAWSnapshot.h"
#import "FBConfiguration.h"

@implementation QAWSnapshot

+ (id<FBXCElementSnapshot>)takeNativeSnapshot:(XCUIElement *)element withDepth:(NSNumber *) depth {
    NSNumber * originalMaxDepth = @(FBConfiguration.snapshotMaxDepth);
    [FBConfiguration setSnapshotMaxDepth:depth];
    id<FBXCElementSnapshot> snapshot =  [element fb_nativeSnapshot];
    [FBConfiguration setSnapshotMaxDepth:originalMaxDepth];
    return snapshot;
}

@end
