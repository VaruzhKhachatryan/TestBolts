//
//  NSData+SC_BFTask.h
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/8/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

@interface NSData (SC_BFTask)

-(BFTask *)sc_writeAsync:(NSString *)path;

+(BFTask *)sc_readAsync:(NSString *)path;

@end
