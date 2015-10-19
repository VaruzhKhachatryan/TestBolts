//
//  SCFBSDKPublishActionsManager.m
//  FacebookSDKHelper
//
//  Created by Karen Ghandilyan on 8/10/15.
//  Copyright (c) 2015 PicsArt. All rights reserved.
//

#import "SCFBSDKPublishActionsManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "SCFBSDKHelperConstants.h"
#import "SCFBSDKAccessManager.h"
@interface SCFBSDKPublishActionsManager()<FBSDKSharingDelegate, FBSDKAppInviteDialogDelegate>

@property (nonatomic, copy) void (^shareDialogCallback)(SCFBSDKResult *result);
@property (nonatomic, copy) void (^inviteDialogCallback)(SCFBSDKResult *result);

@end

@implementation SCFBSDKPublishActionsManager


+ (SCFBSDKPublishActionsManager *)publishActionsManager {
    SCFBSDKPublishActionsManager *manager = [[SCFBSDKPublishActionsManager alloc] init];
    return manager;
    
}
- (void) postToTimelineWithImage:(UIImage *)image
       withParrentViewController:(UIViewController *)viewController
                    withCallback:(void (^)(SCFBSDKResult *result))callback{
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS ] requestMissedPermission:YES withCallback:^(SCFBSDKResult *result) {
        if(result.response != nil) {
            _shareDialogCallback = callback;
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            photo.image = image;
            photo.userGenerated = YES;
            
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[photo];

            FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
            shareDialog.shareContent = content;
            shareDialog.fromViewController = viewController;
            shareDialog.delegate = self;
            
            NSError *validationError;
            [shareDialog validateWithError:&validationError];
            
            if (!validationError && [shareDialog canShow]) {
                [shareDialog show];
            } else {
                NSDictionary *params = @{ @"sourceImage":UIImagePNGRepresentation(image) };
                
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id response, NSError *err) {
                    callback([[SCFBSDKResult alloc] initWithResponse:response error:err cancelled:NO]);
                }];
            }
            
        } else {
            callback(result);
        }
    }];
}

- (void) shareToTimelineWithTitle:(NSString *)title
                      description:(NSString *)description
                         imageUrl:(NSString *)imageUrl
                         shareUrl:(NSString *)shareUrl
        withParrentViewController:(UIViewController *)viewController
                         callback:(void (^)(SCFBSDKResult *result))callback{
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS] requestMissedPermission:YES withCallback:^(SCFBSDKResult *result) {
    
        if (result.response) {
            _shareDialogCallback = callback;
            NSURL *imgUrl = [NSURL URLWithString:imageUrl];
            FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:imgUrl userGenerated:NO];
            NSDictionary *properties = @{
                                         @"og:type": @"picsartphotostudio:photo",
                                         @"og:title": title,
                                         @"og:description": description,
                                         @"og:url": shareUrl,
                                         @"og:image": @[photo]
                                         };
            FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
            
            FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
            action.actionType = @"picsartphotostudio:share";
            [action setObject:object forKey:@"photo"];
            [action setString:@"true" forKey:@"fb:explicitly_shared"];
            
            FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
            content.action = action;
            content.previewPropertyName = @"photo";
            
            FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
            shareDialog.shareContent = content;
            shareDialog.fromViewController = viewController;
            shareDialog.delegate = self;
            
            NSError *validationError;
            
            [shareDialog validateWithError:&validationError];
            
            if (!validationError && [shareDialog canShow]) {
                [shareDialog show];
            } else {
                FBSDKShareLinkContent *linkContent = [[FBSDKShareLinkContent alloc] init];
                linkContent.contentURL = [NSURL URLWithString:shareUrl];
                linkContent.contentTitle = title;
                linkContent.contentDescription = description;
                shareDialog.shareContent = linkContent;
                [shareDialog show];
            }
            
        } else {
            callback(result);
        }
    }];
}

- (void) shareLinkToFeedWithTitle:(NSString *)title
                      description:(NSString *)description
                             link:(NSString *)link
                         imageUrl:(NSString *)imageUrl
        withParrentViewController:(UIViewController *)viewController
                         callback:(void (^)(SCFBSDKResult *))callback {


    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS] requestMissedPermission:YES withCallback:^(SCFBSDKResult *result) {
        if (result.response) {
            _shareDialogCallback = callback;
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentTitle = title;
            content.contentDescription = description;
            content.contentURL = [NSURL URLWithString:link];
            content.imageURL = [NSURL URLWithString:imageUrl];

            [FBSDKShareDialog showFromViewController:viewController withContent:content delegate:self];
            
        } else {
            callback(result);
        }
    }];
    
}

- (void)sendItemWithMessangerWithTitle:(NSString *)title
                              shareUrl:(NSString *)shareUrl
                              imageUrl:(NSString *)imageUrl
                              callback:(void (^)(SCFBSDKResult *))callback {
    _shareDialogCallback = callback;
    FBSDKShareLinkContent *linkContent = [[FBSDKShareLinkContent alloc] init];
    linkContent.contentTitle = title;
    linkContent.contentURL = [NSURL URLWithString:shareUrl];
    linkContent.imageURL = [NSURL URLWithString:imageUrl];
    
    FBSDKMessageDialog *shareDialog = [[FBSDKMessageDialog alloc] init];
    shareDialog.shareContent = linkContent;
    shareDialog.delegate = self;
    
    NSError *validationError;
    
    [shareDialog validateWithError:&validationError];
    if (!validationError) {
        if([shareDialog canShow]) {
            [shareDialog show];
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
        }

    } else {
        callback([[SCFBSDKResult alloc] initWithResponse:nil error:validationError cancelled:NO]);
    }
    
    
}

- (void)sendImageWithMessanger:(UIImage *)image
                  withCallback:(void (^)(SCFBSDKResult *result))callback {
    _shareDialogCallback = callback;
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    
    FBSDKMessageDialog *shareDialog = [[FBSDKMessageDialog alloc] init];
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    
    NSError *validationError;
    
    [shareDialog validateWithError:&validationError];
    if (!validationError) {
        if([shareDialog canShow]) {
            [shareDialog show];
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
        }
        
    } else {
        callback([[SCFBSDKResult alloc] initWithResponse:nil error:validationError cancelled:NO]);
    }
}

- (void)sendLinkWithMessanger:(NSURL *)url withCallback:(void (^)(SCFBSDKResult *result))callback {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    
    content.contentURL = url;
    FBSDKMessageDialog *shareDialog = [[FBSDKMessageDialog alloc] init];
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    
    NSError *validationError;
    
    [shareDialog validateWithError:&validationError];
    if (!validationError) {
        if([shareDialog canShow]) {
            [shareDialog show];
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
        }
        
    } else {
        callback([[SCFBSDKResult alloc] initWithResponse:nil error:validationError cancelled:NO]);
    }
}

- (void) uploadVideoWithUrl:(NSURL *)videoUrl
                description:(NSString *)description
               withCallback:(void (^)(SCFBSDKResult *result))callback {
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    NSDictionary *params = @{
                             @"video.mov" : videoData,
                             @"contentType" : @"video/quicktime",
                             @"description" : @"Made with #PicsArt"
                             };
    
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS]
                  requestMissedPermission:YES
                           withCallback:^(SCFBSDKResult *result) {
                               
                               if (result.response) {
                                   [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/videos" parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id response, NSError *error) {
                                       callback([[SCFBSDKResult alloc] initWithResponse:response error:error cancelled:NO]);
                                   }];
                               } else {
                                   callback(result);
                               }
    }];
}

- (void) shareLink:(NSURL *)url withParrentViewController:(UIViewController *)viewController andCallback:(void (^)(SCFBSDKResult *result))callback {
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS] requestMissedPermission:YES withCallback:^(SCFBSDKResult *result) {
        if (result.response) {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];

            content.contentURL = url;
            _shareDialogCallback = callback;
            [FBSDKShareDialog showFromViewController:viewController withContent:content delegate:self];
            
        } else {
            callback(result);
        }
    }];
    
}

- (void) directItemUploadWithMessage:(NSString *)message
                            photoUrl:(NSString *)photoUrl
                         andCallback:(void (^)(SCFBSDKResult *result))callback {
    
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS] requestMissedPermission:NO withCallback:^(SCFBSDKResult *result) {
        if (result.response) {
            NSMutableDictionary *fbParams = [[NSMutableDictionary alloc] initWithCapacity:10];
            fbParams[@"access_token"] = [FBSDKAccessToken currentAccessToken].tokenString;
            fbParams[@"message"] = message;
            fbParams[@"fb:explicitly_shared"] = @1;
            fbParams[@"photo"] = photoUrl;
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/picsartphotostudio:add" parameters:fbParams HTTPMethod:@"POST"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id response, NSError *error) {
                callback([[SCFBSDKResult alloc] initWithResponse:response error:error cancelled:NO]);
            }];
            
        } else {
            callback(result);
        }
    }];

}

- (void)publishOGActionWithPath:(NSString *)path params:(NSDictionary *)params withCallback:(void (^)(FBSDKGraphRequestConnection *connection, id result, NSError *error))callback {
    [[SCFBSDKAccessManager accessManager] checkForPublishPermissions:@[FB_PERMISSION_PUBLISH_ACTIONS] requestMissedPermission:NO withCallback:^(SCFBSDKResult *result) {
        if (result.response) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:path parameters:params HTTPMethod:@"POST"] startWithCompletionHandler:callback];
        } else {
            callback(nil, nil, result.error);
        }
    }];
}
- (void)presentInviteDialogWithTitile:(NSString *) title
                            inviteUrl:(NSString *)inviteUrl
                             imageUrl:(NSString *)imageUrl
                          andCallback:(void (^)(SCFBSDKResult *result))callback {
    _inviteDialogCallback = callback;
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:inviteUrl];
    content.appInvitePreviewImageURL = [NSURL URLWithString:imageUrl];

    FBSDKAppInviteDialog *inviteDialog = [[FBSDKAppInviteDialog alloc] init];
    inviteDialog.content = content;
    inviteDialog.delegate = self;
    
    NSError *validationError;
    [inviteDialog validateWithError:&validationError];
    
    if (!validationError) {
        if ([inviteDialog canShow]) {
            [inviteDialog show];
        } else {
            callback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:NO]);
        }
    }else {
        callback([[SCFBSDKResult alloc] initWithResponse:nil error:validationError cancelled:NO]);
    }
    
}

#pragma mark - FBSDKSharingDelegate

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if (_shareDialogCallback) {
        _shareDialogCallback([[SCFBSDKResult alloc] initWithResponse:results error:nil cancelled:NO]);
    }
}

- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    if (_shareDialogCallback) {
        _shareDialogCallback([[SCFBSDKResult alloc] initWithResponse:nil error:error cancelled:NO]);
    }
}

- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
    if (_shareDialogCallback) {
        _shareDialogCallback([[SCFBSDKResult alloc] initWithResponse:nil error:nil cancelled:YES]);
    }
}

#pragma mark - FBSDKAppInviteDialogDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    if (_inviteDialogCallback) {
        _inviteDialogCallback([[SCFBSDKResult alloc] initWithResponse:results error:nil cancelled:NO]);
    }
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    if (_inviteDialogCallback) {
        _inviteDialogCallback([[SCFBSDKResult alloc] initWithResponse:nil error:error cancelled:NO]);
    }
}


@end
