//
//  SCFBSDKResult.h
//  picsart
//
//  Created by Karen Ghandilyan on 9/16/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCFBSDKResult : NSObject

@property (nonatomic, readonly) BOOL isCancelled;
@property (nonatomic, readonly) id response;
@property (nonatomic, readonly) NSError *error;

- (id)initWithResponse:(id)response error:(NSError *)error cancelled:(BOOL)cancelled;

@end
