//
//  SCGetAnalyticContactsProtocol.h
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/14/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

@protocol SCGetAnalyticContactsProtocol <NSObject>

- (BFTask *)getAnalyticContactsIfHasPermition;

@end
