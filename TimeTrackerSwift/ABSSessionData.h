//
//  ABSSessionData.h
//  ABSTTiPAD
//
//  Created by developer on 4/16/15.
//  Copyright (c) 2015 AbsoluteMobileSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    project =0,
    module = 1,
    issue,
    category,
    weekEnding
} DataSection;

@interface ABSSessionData : NSObject

@property (strong, nonatomic) NSString * token;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSArray * weekEndings;
@property (strong, nonatomic) NSArray * projectInfo;
@property (strong, nonatomic) NSArray * timeEntriesInfo;
@property (strong, nonatomic) NSNumber *selectedWeekID;



@property (nonatomic, strong) NSMutableDictionary * selectedConfiguration;

+ (ABSSessionData *)sessionData;
-(void)clearSessionData;

-(NSString *)keyForDataType:(DataSection)dataType;
-(NSString *)nameKeyForDataType:(DataSection)dataType;
-(NSString *)displayNameForDataType:(DataSection)dataType;

+(BOOL)rememberMeIsOn;
+(void)setRememberMeOn:(BOOL)on;
+(NSString *)getStoredUsername;
+(NSString *)getStoredPassword;
+(NSNumber *)getStoredUserId;
+(void)setStoredPassword:(NSString *)password forUsername:(NSString *)username;
+(void)setStoredUserId:(NSNumber *)userId forUsername:(NSString *)username;

-(float)sumOfHoursForWeekEntries:(NSArray *) timeEntriesInfo_;


@end
