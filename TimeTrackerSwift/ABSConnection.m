//
//  ABSConnection.m
//  ABSTTiPAD
//
//  Created by developer on 4/15/15.
//  Copyright (c) 2015 AbsoluteMobileSolutions. All rights reserved.
//

#import "ABSConnection.h"
#import <UIKit/UIKit.h>
#import "ABSSessionData.h"
//#import "SpinnerViewController.h"

#define BASE_URL @"http://50.63.53.33:8083"
#define LOGIN_URL_STRING @"AuthenticationService.svc/SignIn"
#define WEEKENDINGS_URL_STRING @"TimeTrackerService.svc/weekEndings"
#define PROJECTINFO_URL_STRING @"/TimeTrackerService.svc/employees/%@/projects"
#define TIMEENTRIES_URL_STRING @"/TimeTrackerService.svc/employees/%@/timeEntries/%@"
#define ADDTIME_URL_STRING @"/TimeTrackerService.svc/timeEntries/add"
#define DELETEENTRY_URL_STRING @"/TimeTrackerService.svc/timeEntries/delete/%@"

static ABSConnection * sharedInstance;
@interface ABSConnection (){
 NSURLSession * session;
}

@end

@implementation ABSConnection

+ (ABSConnection *)sharedConnection{
    
        if (sharedInstance) {
        return sharedInstance;
    }
    sharedInstance= [[ABSConnection alloc]init];
    sharedInstance->session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    (sharedInstance->session).configuration.HTTPMaximumConnectionsPerHost=1;
    (sharedInstance->session).configuration.timeoutIntervalForRequest = 20;
    (sharedInstance->session).configuration.timeoutIntervalForResource = 60;
    (sharedInstance->session).configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                                                      @"Content-Type":@"application/json"};
    
    return sharedInstance;
}

#pragma mark -
#pragma mark Authentication

-(void)loginWithUsername:(NSString *)username password:(NSString *)password completionBlock:(void (^) (BOOL))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:LOGIN_URL_STRING relativeToURL:[NSURL URLWithString:BASE_URL]]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSData * passData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString * base64Pass = [passData base64EncodedStringWithOptions:kNilOptions];
   NSData * postData = [NSJSONSerialization dataWithJSONObject:@{@"username":username, @"password":base64Pass} options:NSJSONWritingPrettyPrinted error:nil];
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
#endif
    [[session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
       NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [ABSSessionData sessionData].token = dictionary[@"d"][@"Token"];
        [ABSSessionData sessionData].userId = dictionary[@"d"][@"UserId"];
        NSLog(@"%@", [ABSSessionData sessionData].userId);
        completionBlock(!error&&([(NSHTTPURLResponse *)response statusCode]<400)&&[ABSSessionData sessionData].token.length);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
}

-(NSNumber *)returnId{
    return [ABSSessionData sessionData].userId;
   
}

-(BOOL)isLoggedIn{
    return [ABSSessionData sessionData].token.length;
}

-(void)logOut{
    [session invalidateAndCancel];
    sharedInstance=nil;
}

#pragma mark -
#pragma mark User Data

- (void)fetchWeekEndingsCompletionBlock:(void (^) (NSArray *))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:WEEKENDINGS_URL_STRING relativeToURL:[NSURL URLWithString:BASE_URL]]];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        completionBlock(!error&&([(NSHTTPURLResponse *)response statusCode]<400)?responseArray:nil);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
}

- (void)fetchProjectInfoCompletionBlock:(void (^) (NSArray *))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:PROJECTINFO_URL_STRING,[ABSSessionData sessionData].userId] relativeToURL:[NSURL URLWithString:BASE_URL]]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSData * postData = [NSJSONSerialization dataWithJSONObject:@{@"token":[ABSSessionData sessionData].token} options:NSJSONWritingPrettyPrinted error:nil];
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [[session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        completionBlock(!error&&([(NSHTTPURLResponse *)response statusCode]<400)?responseArray:nil);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
}


- (void)fetchTimeEntriesForWeek:(NSNumber *)weekEndingId completionBlock:(void (^) (NSArray *))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:TIMEENTRIES_URL_STRING,[ABSSessionData sessionData].userId,weekEndingId] relativeToURL:[NSURL URLWithString:BASE_URL]]];

    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSData * postData = [NSJSONSerialization dataWithJSONObject:@{@"token":[ABSSessionData sessionData].token} options:NSJSONWritingPrettyPrinted error:nil];
    
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [[session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        completionBlock(!error&&([(NSHTTPURLResponse *)response statusCode]<400)?responseArray:nil);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
    
}

- (void)addTime:(NSDictionary *)time completionBlock:(void (^) (BOOL))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:ADDTIME_URL_STRING relativeToURL:[NSURL URLWithString:BASE_URL]]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSLog(@"%@", time);
    NSLog(@"%@", [ABSSessionData sessionData].token);
    NSData * postData = [NSJSONSerialization dataWithJSONObject:@{@"token":[ABSSessionData sessionData].token,@"entryLog":time} options:NSJSONWritingPrettyPrinted error:nil];
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [[session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completionBlock(!error);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
    
}

- (void)deleteEntryWithId:(NSNumber *)entryId completionBlock:(void (^) (NSArray *))completionBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:DELETEENTRY_URL_STRING, entryId] relativeToURL:[NSURL URLWithString:BASE_URL]]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    NSData * postData = [NSJSONSerialization dataWithJSONObject:@{@"token":[ABSSessionData sessionData].token} options:NSJSONWritingPrettyPrinted error:nil];
#ifdef TIME_TRACKER
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    [[session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        completionBlock(!error&&([(NSHTTPURLResponse *)response statusCode]<400)?responseArray:nil);
#ifdef TIME_TRACKER
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    }] resume];
     
}

@end
