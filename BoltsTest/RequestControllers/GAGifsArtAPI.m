//
//  GAGifsArtAPI.m
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import "GAGifsArtAPI.h"
#import "OMGHTTPURLRQ.h"
#import "SCFBSDKGetActionsManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GAUserManager.h"
#import "GAUser.h"

static NSString *FACEBOOK_PROVIDER = @"facebook";

static NSString *SIGNIN = @"users/signin.json";
static NSString *SIGNUP = @"users/signup.json";
static NSString *REVISE_USERNAME = @"users/revise/username.json";
static NSString *UPDATE_USER = @"users/update.json";
static NSString *RESET_USER_PASSWORD = @"users/reset.json";
static NSString *UPLOAD_USER_PROFILE_PHOTO = @"users/photo/add.json";
static NSString *UPLOAD_PHOTO = @"photos/add.json";


@interface GAGifsArtAPI ()

@property (nonatomic) NSString *baseUrl;

@end

@implementation GAGifsArtAPI

- (nonnull instancetype)initWithBaseUrl:(NSString *)baseUrl  {
    self = [super init];
    NSParameterAssert(baseUrl);
    _baseUrl = baseUrl;
    
    return self;
}

#pragma mark - Request URL

- (NSString *)signInUrl {
    return [self.baseUrl stringByAppendingString:SIGNIN];
}

- (NSString *)signUpUrl {
    return [self.baseUrl stringByAppendingString:SIGNUP];
}

- (NSString *)reviseUsernameUrl {
    return [self.baseUrl stringByAppendingString:REVISE_USERNAME];
}

- (NSString *)updateUserNameUrl {
    NSString *userKey = [GAUserManager sharedInstance].user.key;
    return  [NSString stringWithFormat:@"%@%@?key=%@",self.baseUrl,UPDATE_USER,userKey];
}

- (NSString *)resetPasswordUrl {
    return [self.baseUrl stringByAppendingString:RESET_USER_PASSWORD];
}

- (NSString *)uploadUserProfilePhotoUrl {
     NSString *userKey = [GAUserManager sharedInstance].user.key;
    return [NSString stringWithFormat:@"%@%@?key=%@",self.baseUrl, UPLOAD_USER_PROFILE_PHOTO, userKey];
}

- (NSString *)uploadPhotoUrl {
    NSString *userKey = [GAUserManager sharedInstance].user.key;
    return [NSString stringWithFormat:@"%@%@?key=%@",self.baseUrl, UPLOAD_PHOTO, userKey];

}


#pragma mark - Requests

- (BFTask *)loginWithParams:(NSDictionary *)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self signInUrl] :params];
    return [[self gifsArtTask:request] continueWithSuccessBlock:^id(BFTask *task) {
        return [self saveUser:task];
    }];
}

- (BFTask *)signUpWithParams:(NSDictionary *)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self signUpUrl] :params];
    return [[self gifsArtTask:request] continueWithSuccessBlock:^id(BFTask *task) {
        return [self saveUser:task];
    }];
}

- (BFTask *)saveUser:(BFTask *)task {
    return [task continueWithSuccessBlock:^id(BFTask *task) {
        BOOL success = [[GAUserManager sharedInstance] saveUserData:task.result];
        
        if (success) {
            return task;
        }
        return [BFTask taskWithError:[NSError errorWithDomain:@"com.gifsArt.saveUserError" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"couldn't save User"}]]; // todo change this error
    }];
    
}

- (BFTask *)resetPasswordWithParams:(NSDictionary *)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self resetPasswordUrl] :params];
    return [self gifsArtTask:request];
}

- (nonnull BFTask *)updateUserInfoRequest:(nonnull NSDictionary *)params {
     NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self updateUserNameUrl] :params];
    return [self gifsArtTask:request];
}

- (nonnull BFTask *)updateUserProfilePhotoRequest:(nonnull id)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self uploadUserProfilePhotoUrl] :params];
    return [self gifsArtTask:request];
}

- (BFTask *)reviseUserNameRequest:(NSDictionary *)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self reviseUsernameUrl] :params];
    return [self gifsArtTask:request];
}

- (nonnull BFTask *)uploadPhotoRequest:(nonnull id)params {
    NSMutableURLRequest *request = [OMGHTTPURLRQ POST:[self uploadPhotoUrl] :params];
    return [self gifsArtTask:request];
}


#pragma mark - Request for Facebook login or signUp

- (BFTask *)loginWithFaceBook {
    return [[self facebookInfoForLogin] continueWithSuccessBlock:^id(BFTask *task) {
        NSMutableDictionary *userInfo = [self facebookUserInfo:task.result];
        return [[self loginWithParams:[self picsartLoginParamsForFacebook:task.result]] continueWithBlock:^id(BFTask *task) {
            return [self checkUserExist:task userInfo:userInfo];
        }];
    }];
}

- (BFTask *)facebookInfoForLogin {
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    [[SCFBSDKGetActionsManager getActionsManager] userInformationWithCallback:^(NSDictionary *response, NSError *error) {
        if (error || response == nil) {
            [task setError:error ? error : [NSError errorWithDomain:@"com.gifsart.facebookError" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"user canceled"}]];//added custom error
        } else {
            [task setResult:response];
        }
    }];
    
    return task.task;
    
}

- (BFTask *)checkUserExist:(BFTask *)task userInfo:(NSMutableDictionary *)userInfo {
    if ([[task.error.userInfo valueForKey:@"reason"] isEqual:@"user_doesnt_exist"]) {
        return [self reviseUserNameTaskWithDictionary:userInfo];
    }
    if (task.error) {
        return task;
    }
    return [self saveUser:task];
    
}

- (BFTask *)reviseUserNameTaskWithDictionary:(NSMutableDictionary *)userInfo {
    return [[self reviseUserNameRequest: @{@"username" : userInfo[@"checkedUsername"]} ] continueWithSuccessBlock:^id(BFTask *task) {
        return  [[self signUpToGifsArtWithFacebook:[self changeUserName:userInfo task:task]] continueWithSuccessBlock:^id(BFTask *task) {
            return [BFTask taskWithResult:@"signUpFromFacebook"];
        }];
        
    }];
    
}

- (NSMutableDictionary *)changeUserName:(NSMutableDictionary *)userInfo task:(BFTask *)task {
    
    NSDictionary *checkResult = task.result;
    
    NSString *exists = [checkResult[@"exists"] description];
    
    if ([exists isEqual:@"1"]) {
        NSArray *variants = checkResult[@"variants"];
        userInfo[@"checkedUsername"] = variants.firstObject;
    }
    
    return userInfo;
    
}

- (NSDictionary *)picsartLoginParamsForFacebook:(id)result {
    
    NSString *jsonString = @"";
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (! jsonData) {
        NSLog(@"Got an error: %@", jsonError);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *picsartLoginParams = @{ @"provider" : FACEBOOK_PROVIDER,
                                          @"token" : [FBSDKAccessToken currentAccessToken].tokenString,
                                          @"auth" : jsonString
                                          };
    
    return picsartLoginParams;
    
}

- (NSMutableDictionary *)facebookUserInfo:(NSDictionary *)result {
    NSString *checkedUsername = result[@"username"];
    
    if (nil == checkedUsername || [checkedUsername isEqual:@""]) {
        checkedUsername = result[@"name"];
        checkedUsername = [checkedUsername lowercaseString];
        checkedUsername = [checkedUsername stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return [[NSMutableDictionary alloc] initWithDictionary:@{@"currenFacebookUserInfo":result,
                                                            @"checkedUsername" : checkedUsername}];

}

- (BFTask *)signUpToGifsArtWithFacebook:(NSDictionary *)result {
    
    NSDictionary *currenFacebookUserInfo = result[@"currenFacebookUserInfo"];
   
    NSString *email = currenFacebookUserInfo[@"email"];
    if (email == nil) {
        email = @"";
    }
    NSString *coverUrl  = currenFacebookUserInfo[@"cover"][@"source"] ? currenFacebookUserInfo[@"cover"][@"source"] : @"";
    NSDictionary *picsartSignupParams = @{  @"provider" : FACEBOOK_PROVIDER,
                                            @"fb_id" : currenFacebookUserInfo[@"id"] ? currenFacebookUserInfo[@"id"] : @"",
                                            @"fb_email" : email,
                                            @"email" : email,
                                            @"name" : currenFacebookUserInfo[@"name"] ? currenFacebookUserInfo[@"name"] : @"",
                                            @"username" : [self validateUsername:currenFacebookUserInfo[@"checkedUsername"]],
                                            @"photo" : [NSString stringWithFormat:@"%@%@/picture?type=large", FB_GRAPH_PATH_BASE_URL, currenFacebookUserInfo[@"id"]],
                                            @"cover" : coverUrl
                                            };
    
    return [self signUpWithParams:picsartSignupParams];
    
}

- (NSString *)validateUsername:(NSString *)username {
    username = [username lowercaseString];
    
    NSString* filterString = @"^[abcdefghijklmnopqrstuvwxyz0123456789/-]{3,20}$";
    
    NSCharacterSet* set = [[NSCharacterSet characterSetWithCharactersInString:filterString] invertedSet];
    
    NSRange range = [username rangeOfCharacterFromSet:set];
    
    while (range.length > 0) {
        username = [username stringByReplacingCharactersInRange:range withString:@""];
        range = [username rangeOfCharacterFromSet:set];
    }
    
    return username ? username : @"";
}


#pragma mark -  Request Tasks

- (BFTask *)gifsArtTask:(NSURLRequest *)request {
    return [[[self task:request] continueWithSuccessBlock:^id(BFTask *task) {
       return [self apiResultForRequest:task];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        return task;
    }];
}

- (BFTask *)apiResultForRequest :(BFTask *)task {
    NSError *jsonError = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:&jsonError];
    
    if (jsonError) {
        return [BFTask taskWithError:jsonError];
    }
    
    NSError *error = [self apiCheckResult:result];
    if (error) {
        return [BFTask taskWithError:error];
    }
    return [BFTask taskWithResult:result];
}

- (NSError *)apiCheckResult:(id)result {
    if (result == nil || ![result isKindOfClass:[NSDictionary class]] || ![@"success" isEqualToString:result[@"status"]]) {
        if (result != nil) {
            NSString *message = @"Connection Error";
            NSString *reason = @"Unknown_reason";
            if ([result isKindOfClass:[NSDictionary class]]) {
                if (result[@"message"]) {
                    message = result[@"message"];
                }
                if (result[@"reason"]) {
                    reason = result[@"reason"];
                }
            }
            NSDictionary *dict = @{@"message" : message, @"reason" : reason};
            NSError *error = [[NSError alloc] initWithDomain:@"server_error_domain" code:1 userInfo:dict];
            return error;
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Connection Error", @"message",
                                  @"connection_error", @"reason", nil];
            NSError *error = [[NSError alloc] initWithDomain:@"server_error_domain_null_result" code:1 userInfo:dict];
            return error;
        }
    }
    return nil;
}

- (BFTask *)task:(NSURLRequest *)request {
    NSParameterAssert(request);
    if (request == nil) {
        [NSException raise:@"request cant be nil" format:@""];
    }
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [task setError:error];
        } else {
            [task setResult:data];
        }
    }] resume];
    
    return task.task;
}

@end
