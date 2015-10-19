//
//  SCGetDeviceAnalyticContacts.m
//  picsart
//
//  Created by Varuzhan Khachatryan on 10/14/15.
//  Copyright © 2015 Socialin Inc. All rights reserved.
//

#import "SCGetDeviceAnalyticContacts.h"

@interface SCGetDeviceAnalyticContacts ()

@end

@implementation SCGetDeviceAnalyticContacts

static NSString *const deviceContactTypeKey = @"deviceContacts";

- (BFTask *)getAnalyticContactsIfHasPermition{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    NSObject <SCContactsProtocol>* contactStore = DeviceSystemMajorVersion() > 8 ? [[SCCNContactStore alloc] init] : [[SCABAddressBook alloc] init];
    
    if (![contactStore authorizationStatusNegative]){
        NSArray *keys = DeviceSystemMajorVersion() > 8 ? @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactSocialProfilesKey] : @[];
        
        NSMutableArray *contacts = [[NSMutableArray alloc]init];
        NSArray *contactSyncKeys = [SCGetDeviceAnalyticContacts contactSyncKeys];
        
        NSError *error;
        [contactStore enumerateContactsWithKeys:keys error:&error usingBlock:^(SCContact *contact) {
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc]init];
            
            for (NSString *phoneNumber in contact.phoneNumbers) {
                NSString *modifiedString = [[phoneNumber componentsSeparatedByCharactersInSet:
                                             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                            componentsJoinedByString:@""];
                modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"+" withString:@"00"];
                [phoneNumbers addObject:modifiedString];
            }
            if (!contact.socialProfiles.count) {
                if (contact.emails.count || phoneNumbers.count) {
                    NSMutableDictionary *contactDict = [[NSMutableDictionary alloc]init];
                    [contactDict addEntriesFromDictionary:@{@"contact_sync" : @"phone"}];
                    if (contact.emails.count) {
                        [contactDict addEntriesFromDictionary:@{@"emails" : contact.emails}];
                    }
                    if (phoneNumbers.count) {
                        [contactDict addEntriesFromDictionary:@{@"phone" : phoneNumbers}];
                    }
                    [contacts addObject:contactDict];
                }
            }else{
                for (NSDictionary *socialProfile in contact.socialProfiles) {
                    NSString *userId = @"";
                    if(socialProfile[@"identifier"] || socialProfile[@"username"]){
                        userId = socialProfile[@"identifier"] ? socialProfile[@"identifier"] : socialProfile[@"username"];
                    }
                    NSString *contactSyncKey = @"phone";
                    for (NSString *syncKey in contactSyncKeys) {
                        if ([socialProfile[@"service"] rangeOfString:syncKey].location != NSNotFound) {
                            contactSyncKey = syncKey;
                            break;
                        }
                    }
                    if (userId.length || contact.emails.count || phoneNumbers.count) {
                        NSMutableDictionary *contactDict = [[NSMutableDictionary alloc]init];
                        [contactDict addEntriesFromDictionary:@{@"contact_sync" : contactSyncKey}];
                        if (contact.emails.count) {
                            [contactDict addEntriesFromDictionary:@{@"emails" : contact.emails}];
                        }
                        if (phoneNumbers.count) {
                            [contactDict addEntriesFromDictionary:@{@"phone" : phoneNumbers}];
                        }
                        if (userId.length) {
                            [contactDict addEntriesFromDictionary:@{@"identifier" : [userId lowercaseString]}];
                        }
                        [contacts addObject:contactDict];
                    }
                    
                }
            }
        }];
        
        NSInteger lastContactsCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"last_contacts_count"];
        if ((contacts.count - lastContactsCount) > [SCSocialinPropsItem props].contactsChangesMinCount) {
            if (error) {
                [task setError:error];
            } else if(contacts){
                [task setResult:@{@"contact_source" : @"device_contact", @"value" : contacts}];
            }
            return task.task;
        }
    }
    [task cancel];
    
    return task.task;
}

+ (NSArray *)contactSyncKeys{
    return @[@"facebook", @"twitter", @"skype", @"instagram", @"google", @"whatsapp", @"linkedin", @"viber"];
}

@end
