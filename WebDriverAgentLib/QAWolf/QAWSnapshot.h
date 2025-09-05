//
//  QAWSnapshot.h
//  ios-agent
//
//  Created by Elton Carreiro on 04/09/25.
//

#import <Foundation/Foundation.h>
#import "FBXCElementSnapshot.h"

@interface QAWSnapshot : NSObject

+ (id<FBXCElementSnapshot>)takeNativeSnapshot:(XCUIElement *)element withDepth:(NSNumber *) depth;

@end
