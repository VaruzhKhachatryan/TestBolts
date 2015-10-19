//
//  SCContactsSender.m
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/7/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "SCContactsSender.h"
#import "NSURLSession+SCSessionTask.h"
#import "NSData+SC_BFTask.h"
#import "SCGetDeviceAnalyticContacts.h"
#import "SCGetFacebookAnalyticContacts.h"
#import "SCGetTwitterAnalyticContacts.h"
#import "SCGetInstagramAnalyticContacts.h"

@interface SCContactsSender ()
@property (nonatomic) BFTask *sendTask;
@property (nonatomic) NSTimer *timer;
@end

@implementation SCContactsSender

static NSString *const deviceContactTypeKey = @"deviceContacts";
static NSString *const facebookContactTypeKey = @"fbContacts";
static NSString *const twitterContactTypeKey = @"twitterContacts";
static NSString *const instagramContactTypeKey = @"instgramContacts";

static const int dayInSeconds = 86400;

+ (instancetype)sharedInstance {
    static SCContactsSender *__sharedSender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedSender = [[SCContactsSender alloc] init];
    });
    return __sharedSender;
}

#pragma mark - send methods

-(BFTask *)sendTask {
    if (_sendTask == nil) {
        return [BFTask taskWithResult:@(1)];
    }
    return _sendTask;
}

- (void)sendFacebookContactsIfNeeded{
    if ([SCContactsSender isfacebookSendDay]) {
        SCGetFacebookAnalyticContacts *deviceContactsGetter = [[SCGetFacebookAnalyticContacts alloc]init];
        [[deviceContactsGetter getAnalyticContactsIfHasPermition] continueWithSuccessBlock:^id(BFTask *task) {
            return [self sendContacts:task.result contactTypeKey:facebookContactTypeKey];
        }];
    }
}

- (void)sendTwitterContactsIfNeeded{
    if ([SCContactsSender isTwitterSendDay]) {
        SCGetTwitterAnalyticContacts *deviceContactsGetter = [[SCGetTwitterAnalyticContacts alloc]init];
        [[deviceContactsGetter getAnalyticContactsIfHasPermition] continueWithSuccessBlock:^id(BFTask *task) {
            return [self sendContacts:task.result contactTypeKey:twitterContactTypeKey];
        }];
    }
}

- (void)sendInstagramContactsIfNeeded{
    if ([SCContactsSender isInstagramSendDay]) {
        SCGetInstagramAnalyticContacts *deviceContactsGetter = [[SCGetInstagramAnalyticContacts alloc]init];
        [[deviceContactsGetter getAnalyticContactsIfHasPermition] continueWithSuccessBlock:^id(BFTask *task) {
            return [self sendContacts:task.result contactTypeKey:instagramContactTypeKey];
        }];
    }
}


- (BFTask *)sendContacts:(nonnull NSArray *)contacts contactTypeKey:(NSString *)key {
    NSArray *formatedContacts = contacts;
    self.sendTask = [self.sendTask continueWithSuccessBlock:^id(BFTask *task) { //keeping new task to handle new task complition
        NSLog(@"boooooooolt2 key : %@",key);
        return [self sendContactsPrivate:formatedContacts key:key];;
    }];
    return self.sendTask;
}

- (BFTask *)sendContactsPrivate:(NSArray *)formatedContacts key:(NSString *)key{
    return [[[self saveContacts:formatedContacts key:key] continueWithSuccessBlock:^id(BFTask *task) {
        NSLog(@"boooooooolt %@ save",key);
        [SCContactsSender setNextSendDayWithKey:key];
        return [self sendAndRemoveWithData:task.result key:key];
    }]continueWithBlock:^id(BFTask *task) {
        return @(1);
    }];
}

- (BFTask *)sendAndRemoveWithData:(NSData *)data key:(NSString *)key{
    return [[self sendContactsWithData:data] continueWithSuccessBlock:^id(BFTask *task) {
        NSLog(@"boooooolts data is sent : type :%@",key);
        return @(1);//[self removeContactsWithKey:key];
    }];
}

- (BFTask *)readAndSendWithContactType:(NSString *)contactType{
    return [[NSData sc_readAsync:[SCContactsSender pathForKey:contactType]] continueWithBlock:^id(BFTask *task) {
        if (task.result) {
            return [self sendAndRemoveWithData:task.result key:contactType];
        }
        return [BFTask taskWithError:[NSError errorWithDomain:@"com.picsart.contacts" code:-16 userInfo:nil]];
    }];
}

//-(void)logoutObserver:(NSNotification *)notification{
//    [[[[self removeContactsWithKey:deviceContactTypeKey]continueWithBlock:^id(BFTask *task) {
//        return [self removeContactsWithKey:facebookContactTypeKey];
//    }]continueWithBlock:^id(BFTask *task) {
//        return [self removeContactsWithKey:twitterContactTypeKey];
//    }]continueWithBlock:^id(BFTask *task) {
//        return [self removeContactsWithKey:instagramContactTypeKey];
//    }];
//}

-(void)startSendingUnsentContacts {
    [self.timer invalidate];
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                          interval:self.timeInterval
                                            target:self
                                          selector:@selector(sendContactFilesIfNeeded)
                                          userInfo:nil
                                           repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(NSUInteger)timeInterval {
    return 60;
}

+(BOOL)fileExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[SCContactsSender pathForKey:deviceContactTypeKey]] ||
    [[NSFileManager defaultManager] fileExistsAtPath:[SCContactsSender pathForKey:facebookContactTypeKey]] ||
    [[NSFileManager defaultManager] fileExistsAtPath:[SCContactsSender pathForKey:twitterContactTypeKey]] ||
    [[NSFileManager defaultManager] fileExistsAtPath:[SCContactsSender pathForKey:instagramContactTypeKey]];
}

- (BFTask *)sendContactsFromFiles{
    return [[[[[self readAndSendWithContactType:deviceContactTypeKey] continueWithBlock:^id(BFTask *task) {
        return [self readAndSendWithContactType:facebookContactTypeKey];
    }]continueWithBlock:^id(BFTask *task) {
        return [self readAndSendWithContactType:twitterContactTypeKey];
    }]continueWithBlock:^id(BFTask *task) {
        return [self readAndSendWithContactType:instagramContactTypeKey];
    }]continueWithBlock:^id(BFTask *task) {
        return @(1);
    }];
    
}

- (void)sendContactFilesIfNeeded {
    if (_sendTask == nil || _sendTask.completed) { // checking if current task is complited or exists
        if ([SCContactsSender fileExists]) {
            [self sendContactsFromFiles];
            return;
        }
        [self.timer invalidate];
    }
}

#pragma mark - file manager methods

-(BFTask *)saveContacts:(NSArray *)formatedContacts key:(NSString *)key{
    NSString *filePath = [SCContactsSender pathForKey:key];
    return [[BFTask taskFromExecutor:[BFExecutor defaultExecutor] withBlock:^id{
        NSLog(@"boooooooolt %@ making data",key);
        NSError *dataError;
        return [NSJSONSerialization dataWithJSONObject:formatedContacts options:0 error:&dataError];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSLog(@"boooooooolt %@ data is made",key);
        return [task.result sc_writeAsync:filePath];
    }];
}

-(BFTask *)sendContactsWithData:(NSData *)data {
    NSURL *contactSUrl = [NSURL URLWithString:@"https://analytics.picsart.com/secure"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:contactSUrl];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60.0];
    
    return [[NSURLSession sharedSession] request:request];
}

+(NSString *)pathForKey:(NSString *)key {
  //  return [[[SCSocialin sharedInstance] getContactsCacheFolderPath] stringByAppendingPathComponent:[key stringByAppendingPathExtension:@"txt"]];
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                            inDomains:NSUserDomainMask] lastObject];
    return [url.path stringByAppendingPathComponent:@"key"];
}

+(NSDictionary *)sessionHeaderWithSesionId:(NSString*)sessionId {
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSString *versionString = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *) kCFBundleVersionKey];
    
    NSMutableDictionary *headerParams = [NSMutableDictionary new];
    [self safeSetValue:@"apple" forKey:@"platform" inDictionary:headerParams];
    [self safeSetValue:@"" forKey:@"market" inDictionary:headerParams];
    [self safeSetValue:versionString forKey:@"version" inDictionary:headerParams];
    [self safeSetValue:@"1.5" forKey:@"v" inDictionary:headerParams];
    [self safeSetValue:@"" forKey:@"device_id" inDictionary:headerParams];
    [self safeSetValue:languageCode forKey:@"language_code" inDictionary:headerParams];
    [self safeSetValue:countryCode forKey:@"country_code" inDictionary:headerParams];
    [self safeSetValue:sessionId forKey:@"session_id" inDictionary:headerParams];
    
    return headerParams;
}

+(void)safeSetValue:(NSObject *)value
             forKey:(id <NSCopying>)key
       inDictionary:(NSMutableDictionary *)dictionary {
    if (value != nil && key != nil){
        dictionary[key] = value;
    }
}

#pragma mark - check send day

+ (BOOL)isSendDayWithKey:(NSString *)key{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:key]) {
        NSDate *sendDay = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        
        NSComparisonResult result = [sendDay compare:[NSDate date]];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            return YES;
        }
    }else {
        return YES;
    }
    return NO;
}

+ (BOOL)isDeviceSendDay{
    return [SCContactsSender isSendDayWithKey:deviceContactTypeKey];
}

+ (BOOL)isfacebookSendDay{
    return [SCContactsSender isSendDayWithKey:facebookContactTypeKey];
}

+ (BOOL)isTwitterSendDay{
    return [SCContactsSender isSendDayWithKey:twitterContactTypeKey];
}

+ (BOOL)isInstagramSendDay{
    return [SCContactsSender isSendDayWithKey:instagramContactTypeKey];
}

+ (BFTask *)setNextSendDayWithKey:(NSString *)key{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    NSDate *nextSendDay = [NSDate dateWithTimeInterval:5 * dayInSeconds sinceDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:nextSendDay forKey:key];
    
    [task setResult:@(1)];
    return task.task;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
