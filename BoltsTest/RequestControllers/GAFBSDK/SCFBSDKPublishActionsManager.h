//
//  SCFBSDKPublishActionsManager.h
//  FacebookSDKHelper
//
//  Created by Karen Ghandilyan on 8/10/15.
//  Copyright (c) 2015 PicsArt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCFBSDKResult.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@class FBSDKGraphRequestConnection;
@interface SCFBSDKPublishActionsManager : NSObject

+ (SCFBSDKPublishActionsManager *)publishActionsManager;

// FBPostTypeAddToTimeline
- (void) postToTimelineWithImage:(UIImage *)image
       withParrentViewController:(UIViewController *)viewController
                    withCallback:(void (^)(SCFBSDKResult *result))callback;

//FBPostTypeShareToTimeline
- (void) shareToTimelineWithTitle:(NSString *)title
                      description:(NSString *)description
                         imageUrl:(NSString *)imageUrl
                         shareUrl:(NSString *)shareUrl
        withParrentViewController:(UIViewController *)viewController
                         callback:(void (^)(SCFBSDKResult *result))callback;

//FBPostTypeLinkShare
- (void) shareLinkToFeedWithTitle:(NSString *)title
                      description:(NSString *)description
                             link:(NSString *)link
                         imageUrl:(NSString *)imageUrl
        withParrentViewController:(UIViewController *)viewController
                         callback:(void (^)(SCFBSDKResult *result))callback;

// FBPostTypeMessageImage post send

- (void)sendItemWithMessangerWithTitle:(NSString *)title
                              shareUrl:(NSString *)shareUrl
                              imageUrl:(NSString *)imageUrl
                              callback:(void (^)(SCFBSDKResult *result))callback;


- (void)sendImageWithMessanger:(UIImage *)image withCallback:(void (^)(SCFBSDKResult *result))callback;

- (void)sendLinkWithMessanger:(NSURL *)url withCallback:(void (^)(SCFBSDKResult *result))callback;

// FBPostTypeVideoUplaod
- (void) uploadVideoWithUrl:(NSURL *)videoUrl
                description:(NSString *)description
               withCallback:(void (^)(SCFBSDKResult *result))callback;


- (void) shareLink:(NSURL *)url withParrentViewController:(UIViewController *)viewController andCallback:(void (^)(SCFBSDKResult *result))callback;

- (void) directItemUploadWithMessage:(NSString *)message photoUrl:(NSString *)photoUrl andCallback:(void (^)(SCFBSDKResult *result))callback;

- (void) publishOGActionWithPath:(NSString *)path params:(NSDictionary *)params withCallback:(void (^)(FBSDKGraphRequestConnection *connection, id result, NSError *error))callback;

- (void)presentInviteDialogWithTitile:(NSString *) title inviteUrl:(NSString *)inviteUrl imageUrl:(NSString *)imageUrl andCallback:(void (^)(SCFBSDKResult *result))callback;

@end
