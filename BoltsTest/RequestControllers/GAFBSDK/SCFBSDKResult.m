//
//  SCFBSDKResult.m
//  picsart
//
//  Created by Karen Ghandilyan on 9/16/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "SCFBSDKResult.h"

@implementation SCFBSDKResult

- (id)initWithResponse:(id)response error:(NSError *)error cancelled:(BOOL)cancelled {
    self = [super init];
    if (self) {
        _response = response;
        _error = error;
        _isCancelled = cancelled;
    }
    return self;
}

@end
