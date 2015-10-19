//
//  SCContactsSender.h
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/7/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

@interface SCContactsSender : NSObject

+ (nonnull instancetype)sharedInstance;

- (void)sendFacebookContactsIfNeeded;

- (void)sendTwitterContactsIfNeeded;

- (void)sendInstagramContactsIfNeeded;

- (void)startSendingUnsentContacts;

@end
