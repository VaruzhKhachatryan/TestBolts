//
//  SCFBSDKAccessManager.h
//  picsart
//
//  Created by Karen Ghandilyan on 9/16/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCFBSDKResult.h"
@interface SCFBSDKAccessManager : NSObject


+ (SCFBSDKAccessManager *)accessManager;

+ (BOOL)hasActiveSession;

- (void)openFacebookSessionWithCallback:(void (^)(SCFBSDKResult *result))callback;

- (void)checkFacebookSessionWithCallback:(void (^)(SCFBSDKResult *result))callback;

- (void)closeFacebookSession;

- (void)checkForPublishPermissions:(NSArray *)permissions requestMissedPermission:(BOOL)withRequest withCallback:(void(^)(SCFBSDKResult *result))callback;


@end
