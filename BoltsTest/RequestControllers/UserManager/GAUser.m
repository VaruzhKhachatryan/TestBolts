//
//  GAUser.m
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import "GAUser.h"

@implementation GAUser

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.userId = [dictionary[@"id"] description];
        self.name = [dictionary[@"name"] description];
        self.username = [dictionary[@"username"] description];
        self.photo = [dictionary[@"photo"] description];
        self.cover = [dictionary[@"cover"] description];
        self.email = [dictionary[@"email"] description];
        self.fb_id = [dictionary[@"fb_id"] description];
        self.fb_token = [dictionary[@"token"] description];
        self.social_provider = [dictionary[@"social_provider"] description];
        self.following_count = [dictionary[@"following_count"] intValue];
        self.followers_count = [dictionary[@"followers_count"] intValue];
        self.photos_count = [dictionary[@"photos_count"] intValue];
        self.streams_count = [dictionary[@"streams_count"] intValue];
        self.tags_count = [dictionary[@"tags_count"] intValue];
        self.balance = [dictionary[@"balance"] intValue];
        self.is_mature = [dictionary[@"mature"] intValue];        
        self.key = [dictionary[@"key"] description];
    }
    return self;
}

- (void)setBalance:(int)balance {
    if (balance < 0) {
        balance = 0;
    }
    _balance = balance;
}

- (NSString *)email {
    if(!_email || [[_email description] isEqual:@"<null>"]) { // or _email == (id)[NSNull null]
        return @"";
    }
    return _email;
}

- (NSString *)fb_id {
    if(!_fb_id || [[_fb_id description] isEqual:@"<null>"]) {
        return @"";
    }
    return _fb_id;
}

- (NSString *)fb_token {
    if(!_fb_token || [[_fb_token description] isEqual:@"<null>"]) {
        return @"";
    }
    return _fb_token;
}

- (NSString *)social_provider {
    if(!_social_provider || [[_social_provider description] isEqual:@"<null>"]) {
        return @"";
    }
    return _social_provider;
}

- (NSString *)key {
    if(!_key || [[_key description] isEqual:@"<null>"]) {
        return @"";
    }
    return _key;
}

- (NSString *)cover {
    if(!_cover || [[_cover description] isEqual:@"<null>"]) {
        return @"";
    }
    if ([_cover rangeOfString:@"?r1024x1024"].location == NSNotFound && [_cover rangeOfString:@"picsart.com"].location != NSNotFound) {
        _cover = [NSString stringWithFormat:@"%@?r1024x1024", _cover];
    }
    return [_cover stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
}

- (NSDictionary *)userDictionary {
    NSDictionary *dictionary =@{ @"id" :self.userId,
                                 @"name" : self.name,
                                 @"username" : self.username,
                                 @"photo": self.photo,
                                 @"email": self.email,
                                 @"cover": self.cover,
                                 @"fb_id": self.fb_id,
                                 @"token": self.fb_token,
                                 @"social_provider": self.social_provider,
                                 @"following_count": @(self.following_count),
                                 @"followers_count": @(self.followers_count),
                                 @"photos_count": @(self.photos_count),
                                 @"streams_count": @(self.streams_count),
                                 @"tags_count": @(self.tags_count),
                                 @"balance": @(self.balance),
                                 @"mature": @(self.is_mature),
                                 @"key": self.key
                                 };
    return dictionary;
}

//-(NSString*)ovalUserPhoto {
//    return [self userOvalphotoForSize:CGSizeMake(120, 120) cropChar:@"c"];
//}
//
//-(NSString*)ovalUserPhotoForProfile {
//    return [self userOvalphotoForSize:CGSizeMake(240, 240) cropChar:@"r"];
//}
//
//-(NSString *)userOvalphotoForSize:(CGSize)size cropChar:(NSString *)cropChar {
//    NSString* userPhoto = self.photo;
//    
//    if ([userPhoto rangeOfString:@"graph.facebook.com"].length) {
//        NSString *joinChar = [userPhoto rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
//        userPhoto = [NSString stringWithFormat:@"%@%@type=large&o%dx%d", userPhoto, joinChar, (int)size.width, (int)size.height];
//    } else if([userPhoto rangeOfString:@"googleusercontent.com"].length) {
//        userPhoto = [userPhoto substringToIndex:[userPhoto rangeOfString:@"photo.jpg"].location + 9];
//        userPhoto = [NSString stringWithFormat:@"%@?sz=240&o%dx%d", userPhoto, (int)size.width, (int)size.height];
//    } else if ([userPhoto rangeOfString:@"twimg.com"].length) {
//        
//        if (size.width > 200 || size.height > 200) {
//            userPhoto = [userPhoto stringByReplacingOccurrencesOfString:@"_bigger" withString:@""];
//            userPhoto = [NSString stringWithFormat:@"%@?o%dx%d", userPhoto, (int)size.width, (int)size.height];
//        }else {
//            userPhoto = [NSString stringWithFormat:@"%@?o%dx%d", userPhoto, (int)size.width, (int)size.height];
//        }
//    } else {
//        userPhoto = [NSString stringWithFormat:@"%@?%@%dx%d&o%dx%d", userPhoto, cropChar, (int)size.width, (int)size.height, (int)size.width, (int)size.height];
//    }
//    
//    return  userPhoto;
//}

@end
