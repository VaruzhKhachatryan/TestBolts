//
//  SCGetAnalyticContactsProtocol.h
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/14/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

//33333333333

@protocol SCGetAnalyticContactsProtocol <NSObject>

- (BFTask *)getAnalyticContactsIfHasPermition;

@end
