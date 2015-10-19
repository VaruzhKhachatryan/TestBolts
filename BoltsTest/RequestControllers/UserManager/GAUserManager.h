//
//  GAUserManager.h
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GAUser;

#define kPAUserDataKey @"pa_user_data"

#define kPAUserLoggedInKey @"pa_user_logged_in"
#define kPAUserLoggedOutKey @"pa_user_logged_out"

@interface GAUserManager : NSObject

@property(nonatomic) GAUser *user;

+ (GAUserManager *)sharedInstance;

-(void)readUser;
-(BOOL)isLoggedIn;
-(BOOL)saveUserData:(NSDictionary *)userDictionary;
-(void)logout;

@end
