//
//  NSURLSession+SCSessionTask.m
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/7/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "NSURLSession+SCSessionTask.h"

@implementation NSURLSession (SCSessionTask)

/**
 Makes a GET request to the provided URL.
 [NSURLConnection GET:@"http://placekitten.com/320/320"].then(^(UIImage *img){
 // PromiseKit decodes the image (if it’s an image)
 });
 @param urlStringFormatOrURL The `NSURL` or string format to request.
 @return A promise that fulfills with three parameters:
 1) The deserialized data response.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.
 */


//todo change request name
- (BFTask *)request:(NSURLRequest *)request {
    NSParameterAssert(request);
    if (request == nil) {
        [NSException raise:@"request cant be nil" format:@""];
    }
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
//    if([SCUtility isNotConnected]){
//        NSError *connectionError = [NSError errorWithDomain:@"com.picsart.studio.connection" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"connection error"}];
//        [task setError:connectionError];
//        return task.task;
//    }
    
    [[self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (error) {
            [task setError:error];
        } else {
            [task setResult:result];
        }
    }] resume];
    
    return task.task;
}


//- (BFTask *)GET:(NSString *)url query:(NSDictionary *)parameters {
//    NSParameterAssert(url);
//    NSLog(@"%@",url);
//    return [[[self request:[OMGHTTPURLRQ GET:url :parameters]] continueWithSuccessBlock:^id(BFTask *task) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
//        return [BFTask taskWithResult:task.result];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        return task;
//    }];
//    
//}
//
//- (BFTask *)POST:(NSString *)url query:(NSData *)body {
//    NSParameterAssert(url);
//    return [[[self request:[OMGHTTPURLRQ POST:url :body]] continueWithSuccessBlock:^id(BFTask *task) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
//        return [BFTask taskWithResult:result];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        return task;
//    }];
//    
//}
//
//
//- (BFTask *)POST:(NSString *)urlString formURLEncodedParameters:(NSDictionary *)parameters {
//    return [[[self request:[OMGHTTPURLRQ POST:urlString :parameters]] continueWithSuccessBlock:^id(BFTask *task) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
//        return [BFTask taskWithResult:result];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        return task;
//    }];
//    
//}
//
//- (BFTask *)POST:(NSString *)urlString JSON:(id)parameters {
//    return [[[self request:[OMGHTTPURLRQ POST:urlString JSON:parameters]] continueWithSuccessBlock:^id(BFTask *task) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
//        return [BFTask taskWithResult:result];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        return task;
//    }];
//    
//}
//
//
//- (BFTask *)POST:(NSString *)urlString multipartFormData:(id)parameters {
//    return [[[self request:[OMGHTTPURLRQ POST:urlString :parameters]] continueWithSuccessBlock:^id(BFTask *task) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
//        return [BFTask taskWithResult:result];
//    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//        return task;
//    }];
//    
//}
///*
// 
// 
// -(BFTask *)task:(NSURLRequest *)request {
// NSParameterAssert(request);
// if (request == nil) {
// [NSException raise:@"request cant be nil" format:@""];
// }
// 
// BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
// [[self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
// if (error) {
// [task setError:error];
// }else {
// [task setResult:data];
// }
// }] resume];
// return task.task;
// }
// 
// -(BFTask *)picsartTask:(NSURLRequest *)request {
// return [[[self task:request] continueWithSuccessBlock:^id(BFTask *task) {
// NSDictionary *result = [NSJSONSerialization JSONObjectWithData:task.result options:0 error:NULL];
// if ([result[@"status"] isEqual:@"success"]) {
// return [BFTask taskWithResult:result];
// }
// return [BFTask taskWithError:[NSError errorWithDomain:@"com.picsart.story" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"Wrong Response", @"response_data": result}]];
// }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
// return task;
// }];
// }
// 
// 
// */


@end
