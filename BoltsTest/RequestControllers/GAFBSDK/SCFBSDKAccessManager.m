//
//  SCFBSDKAccessManager.m
//  picsart
//
//  Created by Karen Ghandilyan on 9/16/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "SCFBSDKAccessManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SCFBSDKHelperConstants.h"

@implementation SCFBSDKAccessManager

+ (SCFBSDKAccessManager *)accessManager {
    SCFBSDKAccessManager *loginManager = [[SCFBSDKAccessManager alloc] init];
    return loginManager;
}

+ (BOOL)hasActiveSession {
    return [FBSDKAccessToken currentAccessToken] != nil;
}


#pragma mark - Public Functions
- (void)openFacebookSessionWithCallback:(void (^)(SCFBSDKResult *result))callback {
    [self closeFacebookSession];
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (accessToken) {
        // user logged in, only need to check for expire
        [self getUserInformationWithCallback:callback];
    } else {
        
        FBSDKLoginManager *facebookLoginManager = [[FBSDKLoginManager alloc] init];
        
        [facebookLoginManager logInWithReadPermissions:[self loginPermisions]
                                               handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                   callback([[SCFBSDKResult alloc] initWithResponse:(error || result.isCancelled) ? nil : @{} error:error cancelled:result.isCancelled]);
                                               }];
    }

    
}
- (void)checkFacebookSessionWithCallback:(void (^)(SCFBSDKResult *result))callback {
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (!accessToken) {
        callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
    } else {
        [self getUserInformationWithCallback:callback];
    }
}


- (void)closeFacebookSession {
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logOut];
}


- (void)checkForPublishPermissions:(NSArray *)permissions requestMissedPermission:(BOOL)withRequest withCallback:(void(^)(SCFBSDKResult *result))callback {
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if(!accessToken) {
        if (withRequest) {
            [self getPublishPermissions:permissions withCallback:callback];
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
        }
        
    } else {
        NSSet *grantedPermissions = accessToken.permissions;
        
        NSMutableArray *requestPermisions = [[NSMutableArray alloc] init];
        NSMutableArray *checkPermisions = [[NSMutableArray alloc] init];
        
        for (NSString *permission in permissions) {
            if ([grantedPermissions containsObject:permission]) {
                [checkPermisions addObject:permission];
            } else {
                [requestPermisions addObject:permission];
            }
        }
        [self checkUserPublishPermissions:checkPermisions requestPermissions:requestPermisions requestMissedPermission:withRequest withCallback:callback];
    }
}

#pragma mark - Private Functions

/**
 User information get method, using for check access token validation
 **/

- (void)getPublishPermissions:(NSArray *)permissions withCallback:(void(^)(SCFBSDKResult *result))callback {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithPublishPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        callback([[SCFBSDKResult alloc] initWithResponse:(error || result.isCancelled) ? nil : @{} error:error cancelled:result.isCancelled]);
    }];
}

- (void)checkUserPublishPermissions:(NSArray *)checkingPermissions requestPermissions:(NSArray *)requestPermissions requestMissedPermission:(BOOL)withRequest withCallback:(void(^)(SCFBSDKResult *result))callback {
    
    [self getUserPermissionsWithCallback:^(id result, NSError *error) {
        NSMutableArray *currentPermissions = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *dict in (NSArray *)result[@"data"]) {
            if ([dict[@"status"] isEqualToString:@"granted"]) {
                [currentPermissions addObject:dict[@"permission"]];
            }
        }
        
        NSMutableArray *reqPermisions = [[NSMutableArray alloc] initWithArray:requestPermissions];
        for (NSString *permission in checkingPermissions) {
            if (![currentPermissions containsObject:permission]) {
                [reqPermisions addObject:permission];
            }
        }
        
        if (reqPermisions.count > 0) {
            if (withRequest) {
                [self getPublishPermissions:reqPermisions withCallback:callback];
            } else {
                callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
            }
            
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:@{} error:nil cancelled:NO]);
        }
    }];
}


- (void)getUserInformationWithCallback:(void (^)(SCFBSDKResult *result))callback {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture, email, gender, first_name, name, link, timezone, cover"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         callback([[SCFBSDKResult alloc] initWithResponse:result error:error cancelled:NO]);
     }];
}


- (void)getUserPermissionsWithCallback:(void(^)(NSDictionary *result, NSError *error))callback {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/permissions" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        callback(result, error);
    }];
}


- (NSArray *) loginPermisions {
    return @[FB_PERMISSION_USER_PHOTOS,
             FB_PERMISSION_EMAIL,
             FB_PERMISSION_USER_FRIENDS];
}


@end
