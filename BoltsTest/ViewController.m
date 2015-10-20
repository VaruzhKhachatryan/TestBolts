//
//  ViewController.m
//  BoltsTest
//
//  Created by Varuzhan Khachatryan on 10/15/15.
//  Copyright © 2015 Varuzhan Khachatryan. All rights reserved.
//

#import "ViewController.h"
#import "SCContactsSender.h"
#import "GASharedState.h"
#import "GAGifsArtAPI.h"
#import "OMGHTTPURLRQ.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[SCContactsSender sharedInstance] sendFacebookContactsIfNeeded];
//    [[SCContactsSender sharedInstance] sendTwitterContactsIfNeeded];
//    [[SCContactsSender sharedInstance] sendInstagramContactsIfNeeded];
    
    [self testBolts];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)testBolts {
    [self loginWithPA];
//    [self loginWithFB];
    [self testParallel];
}

- (void)loginWithPA {
    [[[GASharedState sharedInstance].api loginWithParams:[self getLoginParams]] continueWithBlock:^id(BFTask *task) {
        if (task.result) {
            NSLog(@"loginWithPA all tasks completed ");
        }else {
            NSLog(@"%@",[task.error.userInfo valueForKey:@"message"]);
        }
        return nil;
    }];
}

- (void)loginWithFB {
//    [[[GASharedState sharedInstance].api loginWithFaceBook] continueWithBlock:^id(BFTask *task) {
//        if (task.result) {
//            NSLog(@"all tasks completed ");
//        }else {
//            NSLog(@"%@",[task.error.userInfo valueForKey:@"message"]);
//        }
//        return nil;
//    }];
}

- (NSDictionary *)getLoginParams {
    NSDictionary* picsartLoginParams = @{ @"provider" : @"site",
                                          @"username" : @"testaa1",
                                          @"password" : @"123456"
                                          };
    return picsartLoginParams;
}

- (void)testParallel {
    NSLog(@"Tasks in Parallel");
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    params[@"name"] = @"testaa1";
    
    OMGMultipartFormData *multipartFormData = [[OMGMultipartFormData alloc] init];
    
    [multipartFormData addFile:UIImageJPEGRepresentation([UIImage imageNamed:@"profile_image"], 0.8)
                 parameterName:@"file" filename:@"photo" contentType:@"image/jpeg"];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    [tasks addObject:[[GASharedState sharedInstance].api updateUserProfilePhotoRequest:multipartFormData]];
    [tasks addObject:[[GASharedState sharedInstance].api updateUserInfoRequest:params]];
    
    BFTask *allTasks = [BFTask taskForCompletionOfAllTasksWithResults:tasks];
    [allTasks continueWithBlock:^id(BFTask *task) {
        if (task.error) {
             NSLog(@"error %@",[task.error.userInfo valueForKey:@"message"]);
        }else {
            NSLog(@"testParallel all tasks completed ");
        }
        return nil;
    }];

    
}




@end
