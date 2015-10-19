//
//  NSURLSession+SCSessionTask.h
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/7/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>


@interface NSURLSession (SCSessionTask)

- (BFTask *)request:(NSURLRequest *)request;

- (BFTask *)GET:(NSString *)url query:(NSDictionary *)parameters;

- (BFTask *)POST:(NSString *)url query:(NSData *)body;

- (BFTask *)POST:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters;

- (BFTask *)POST:(NSString *)urlString JSON:(id)parameters;

- (BFTask *)POST:(NSString *)urlString multipartFormData:(id)parameters;


@end
