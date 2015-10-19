//
//  SCGetFacebookAnalyticContacts.m
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/14/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "SCGetFacebookAnalyticContacts.h"

@implementation SCGetFacebookAnalyticContacts

- (BFTask *)getAnalyticContactsIfHasPermition{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [task setResult:@[@"data1",@"data2"]];

    return task.task;
}


@end
