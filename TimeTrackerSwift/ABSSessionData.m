//
//  ABSSessionData.m
//  ABSTTiPAD
//
//  Created by developer on 4/16/15.
//  Copyright (c) 2015 AbsoluteMobileSolutions. All rights reserved.
//

#import "ABSSessionData.h"
#import "KeychainWrapper.h"

#define kRememberMe @"kRememberMe"
#define kProjectInfoConfig @"ProjectInfoConfig"

static ABSSessionData * sharedInstance;

@implementation ABSSessionData


+ (ABSSessionData *)sessionData{
    if (sharedInstance) {
        return sharedInstance;
    }
    sharedInstance= [[ABSSessionData alloc]init];
    sharedInstance.selectedConfiguration=[NSMutableDictionary dictionary];
    return sharedInstance;
}

-(void)clearSessionData{
    sharedInstance=nil;
}
-(NSString *)keyForDataType:(DataSection)dataType{
    switch (dataType) {
        case project:
            return kProjectInfoConfig;

            
        default:
            return @"";
    }
}

-(NSString *)nameKeyForDataType:(DataSection)dataType{
    switch (dataType) {
        case module:
            return @"ModuleName";
            
            
        default:
            return @"Name";
    }
}

-(NSString *)displayNameForDataType:(DataSection)dataType{
    switch (dataType) {
        case project:
            return @"Project";
        case module:
            return @"Module";
        case issue:
            return @"Issue";
        case category:
            return @"Category";
        default:
            return @"";
    }
}

+(BOOL)rememberMeIsOn{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:kRememberMe] boolValue];
}

+(void)setRememberMeOn:(BOOL)on{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:on] forKey:kRememberMe];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSString *)getStoredUsername{
    KeychainWrapper *wrapper = [KeychainWrapper new];
    return [wrapper myObjectForKey:(__bridge id)(kSecAttrAccount)];
}

+(NSString *)getStoredPassword{
    KeychainWrapper *wrapper = [KeychainWrapper new];
    return [wrapper myObjectForKey:(__bridge id)(kSecValueData)];
    
}

//added
+(NSString *)getStoredUserId{
    KeychainWrapper *wrapper = [KeychainWrapper new];
    return [wrapper myObjectForKey:(__bridge id)(kSecValueData)];
    
}
//added
+(void)setStoredUserId:(NSNumber *)userId forUsername:(NSString *)username{
    KeychainWrapper *wrapper = [KeychainWrapper new];
    [wrapper mySetObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper mySetObject:userId forKey:(__bridge id)(kSecValueData)];
    [wrapper writeToKeychain];
}

+(void)setStoredPassword:(NSString *)password forUsername:(NSString *)username{
    KeychainWrapper *wrapper = [KeychainWrapper new];
    [wrapper mySetObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper mySetObject:password forKey:(__bridge id)(kSecValueData)];
    [wrapper writeToKeychain];
}

-(float)sumOfHoursForWeekEntries:(NSArray *) timeEntriesInfo_{
    float sum = 0.0f;
    for (NSDictionary * timeEntry in timeEntriesInfo_){
        sum+=[timeEntry[@"Duration"] floatValue];
    }
    return sum;
}

@end
