//
//  GAUser.h
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAUser : NSObject

- (NSDictionary *)userDictionary;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@property(nonatomic, copy) NSString *fb_id;
@property(nonatomic, copy) NSString *fb_token;
@property(nonatomic, copy) NSString *social_provider;
@property(nonatomic, copy) NSString *key;
@property(nonatomic, copy) NSString *email;
@property(nonatomic) int following_count;
@property(nonatomic) int followers_count;
@property(nonatomic) int photos_count;
@property(nonatomic) int streams_count;
@property(nonatomic) int tags_count;
@property(nonatomic) int balance;
@property(nonatomic) int is_mature;
@property(nonatomic,copy) NSString *cover;

@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *username;

@property (nonatomic) NSString *photo;
@property(nonatomic, readonly, copy) NSString* ovalUserPhoto;
@property(nonatomic, readonly, copy) NSString* ovalUserPhotoForProfile;


@end
