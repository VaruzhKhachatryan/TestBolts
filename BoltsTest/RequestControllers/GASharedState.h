//
//  GASharedState.h
//  GifsArt
//
//  Created by Davit Piloyan on 10/12/15.
//  Copyright © 2015 PicsArt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GAGifsArtAPI;

@interface GASharedState : NSObject

+ (nonnull instancetype)sharedInstance;

@property(nullable, nonatomic, readonly) GAGifsArtAPI *api;

@end
