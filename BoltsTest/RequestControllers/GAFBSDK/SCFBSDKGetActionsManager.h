//
//  SCFBSDKGetActionsManager.h
//  FacebookSDKHelper
//
//  Created by Karen Ghandilyan on 8/10/15.
//  Copyright (c) 2015 PicsArt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCFBSDKHelperConstants.h"

@class FBSDKGraphRequestConnection;

@interface SCFBSDKGetActionsManager : NSObject

/**
 Returns instance of SCFBSDKGetActionsManager
 **/

+ (SCFBSDKGetActionsManager *)getActionsManager;

/**
 Returns user information dictionary (user_id, email, name, profile picture, profile_url, gender)
 **/

- (void) userInformationWithCallback:(void (^)(NSDictionary *response,  NSError *error))callback;

@end
