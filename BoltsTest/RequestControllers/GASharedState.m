//
//  GASharedState.m
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import "GASharedState.h"
#import "GAGifsArtAPI.h"

@interface GASharedState ()

@property (nullable,nonatomic,readwrite) GAGifsArtAPI *api;

@end

@implementation GASharedState

+(nonnull instancetype)sharedInstance {
    static GASharedState *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[GASharedState alloc] init];
        __sharedInstance.api = [[GAGifsArtAPI alloc] initWithBaseUrl:@"https://api.picsart.com/"];
    });
    
    return __sharedInstance;
}

@end
