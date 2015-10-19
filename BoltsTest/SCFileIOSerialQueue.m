//
//  SCFileIOSerialQueue.m
//  picsart
//
//  Created by hovhannes safaryan on 2/22/13.
//  Copyright (c) 2013 Socialin Inc. All rights reserved.
//

#import "SCFileIOSerialQueue.h"

@implementation SCFileIOSerialQueue

+(SCFileIOSerialQueue*)sharedInstance;
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

@synthesize fileIoQueue = _fileIoQueue;
-(dispatch_queue_t)fileIoQueue
{
    if (_fileIoQueue) return _fileIoQueue;
    _fileIoQueue = dispatch_queue_create("com.picsart.studio.fileio", DISPATCH_QUEUE_SERIAL);
    return _fileIoQueue;
}

-(void)dealloc
{
    if (_fileIoQueue) {
        //dispatch_release(_fileIoQueue);
    }
}

@end
