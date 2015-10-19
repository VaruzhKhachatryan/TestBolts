//
//  GAGifsArtAPI.h
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

@interface GAGifsArtAPI : NSObject

- (nonnull instancetype)initWithBaseUrl:(nonnull NSString *)baseUrl;

- (nonnull BFTask *)loginWithParams:(nonnull NSDictionary *)params;

- (nonnull BFTask *)loginWithFaceBook;

- (nonnull BFTask *)reviseUserNameRequest:(nonnull NSDictionary *)params;

- (nonnull BFTask *)updateUserInfoRequest:(nonnull NSDictionary *)params;

- (nonnull BFTask *)updateUserProfilePhotoRequest:(nonnull id)params;

- (nonnull BFTask *)signUpWithParams:(nonnull NSDictionary *)params;

- (nonnull BFTask *)saveUser:(nonnull BFTask *)task;

- (nonnull BFTask *)resetPasswordWithParams:(nonnull NSDictionary *)params;

- (nonnull BFTask *)uploadPhotoRequest:(nonnull id)params;

@end
