//
//  NSData+SC_BFTask.m
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/8/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "NSData+SC_BFTask.h"
#import "SCFileIOSerialQueue.h"

@implementation NSData (SC_BFTask)

-(BFTask *)sc_writeAsync:(NSString *)path {
        NSParameterAssert(path);
//    if (request == nil) {
//        [NSException raise:@"request cant be nil" format:@""];
//    }
    
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
        dispatch_async([SCFileIOSerialQueue sharedInstance].fileIoQueue, ^{
            BOOL success = [self writeToFile:path atomically:YES];
            if (success) {
                [task setResult:self];
            } else {
                [task setError:[NSError errorWithDomain:@"com.picsart.studio.fileio" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Write failed"}]];
            }
        });
        
        return task.task;
}

+(BFTask *)sc_readAsync:(NSString *)path {
    NSParameterAssert(path);
//    if (request == nil) {
//        [NSException raise:@"request cant be nil" format:@""];
//    }
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_async([SCFileIOSerialQueue sharedInstance].fileIoQueue, ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            [task setResult:data];
        } else {
            [task setError:[NSError errorWithDomain:@"com.picsart.studio.fileio" code:-2 userInfo:@{NSLocalizedDescriptionKey:@"Read failed"}]];
        }
    });
    
    return task.task;
}

@end
