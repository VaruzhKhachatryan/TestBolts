//
//  SCFileIOSerialQueue.h
//  picsart
//
//  Created by hovhannes safaryan on 2/22/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

@import Foundation;
@interface SCFileIOSerialQueue : NSObject

+(SCFileIOSerialQueue*)sharedInstance;


@property(nonatomic, readonly) dispatch_queue_t fileIoQueue;

@end
