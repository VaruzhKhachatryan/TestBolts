//
//  SCFBSDKGetActionsManager.m
//  FacebookSDKHelper
//
//  Created by Karen Ghandilyan on 8/10/15.
//  Copyright (c) 2015 PicsArt. All rights reserved.
//

#import "SCFBSDKGetActionsManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SCFBSDKAccessManager.h"
#import "SCFBSDKGetActionsManager.h"


@implementation SCFBSDKGetActionsManager

+ (SCFBSDKGetActionsManager *)getActionsManager {
    SCFBSDKGetActionsManager *manager = [[SCFBSDKGetActionsManager alloc] init];
    return manager;
}

- (void)userInformationWithCallback:(void (^)(NSDictionary *,  NSError *))callback {
    [self checkReadPermisssons:@[FB_PERMISSION_PUBLIC_PROFILE, FB_PERMISSION_EMAIL] withCallback:^(BOOL success, NSError *error) {
        if (success) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email, gender, first_name, name, link, timezone, cover"}]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *err) {
                 if (err) {
                     callback(nil, err);
                     
                 } else {
                     callback(result, nil);
                     NSLog(@"fetched user:%@", result);
                 }
             }];
        } else {
            callback(nil, error);
        }
    }];
    
}

#pragma mark - Private Functions

- (void)checkReadPermisssons:(NSArray *)permissions withCallback:(void (^)(BOOL, NSError *))callback {
    [[SCFBSDKAccessManager accessManager] openFacebookSessionWithCallback:^(SCFBSDKResult *result) {
        callback(result.response!= nil, result.error);
    }];
}

@end
