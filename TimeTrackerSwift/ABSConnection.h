//
//  ABSConnection.h
//  ABSTTiPAD
//
//  Created by developer on 4/15/15.
//  Copyright (c) 2015 AbsoluteMobileSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABSConnection : NSObject <NSURLSessionDelegate>

+ (ABSConnection *)sharedConnection;
@property(nonatomic) BOOL internetConnection;
-(void)loginWithUsername:(NSString *)username password:(NSString *)password completionBlock:(void (^) (BOOL))completionBlock;
-(BOOL)isLoggedIn;
-(void)logOut;
-(NSNumber *)returnId;

- (void)fetchWeekEndingsCompletionBlock:(void (^) (NSArray *))completionBlock;
- (void)fetchProjectInfoCompletionBlock:(void (^) (NSArray *))completionBlock;
- (void)fetchTimeEntriesForWeek:(NSNumber *)weekEndingId completionBlock:(void (^) (NSArray *))completionBlock;
- (void)addTime:(NSDictionary *)time completionBlock:(void (^) (BOOL))completionBlock;
- (void)deleteEntryWithId:(NSNumber *)entryId completionBlock:(void (^) (NSArray *))completionBlock;

@end
