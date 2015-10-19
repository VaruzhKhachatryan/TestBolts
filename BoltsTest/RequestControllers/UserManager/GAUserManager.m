//
//  GAUserManager.m
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import "GAUserManager.h"
#import "GAUser.h"

@implementation GAUserManager

+ (GAUserManager *)sharedInstance {
    static GAUserManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[GAUserManager alloc] init];
    });
    
    return __sharedInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self readUser];
    }
    
    return self;
}

- (void)setUser:(GAUser *)user {
    _user = user;
}

- (void)readUser {
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPAUserDataKey];
    if (nil == userDictionary) {
        self.user = nil;
        return;
    }
    
    self.user = [[GAUser alloc] initWithDictionary:[userDictionary mutableCopy]];
}

- (BOOL)isLoggedIn {
    if (nil == self.user || nil == self.user.key || nil == self.user.userId) {
        return NO;
    }
    
    return YES;
}

- (BOOL)saveUserData:(NSDictionary *)userDictionary {
    GAUser *newUser = [[GAUser alloc] initWithDictionary:userDictionary];
    if (newUser.key.length == 0 || newUser.userId.length == 0) {
        //invalid user
        return NO;
    }
    
    self.user = [[GAUser alloc] initWithDictionary:[userDictionary mutableCopy]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[newUser userDictionary] forKey:kPAUserDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPAUserLoggedInKey object:self userInfo:nil];
    
    return YES;
}

- (void)logout {
    self.user = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAUserDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPAUserLoggedOutKey object:nil userInfo:nil];
}

@end
