//
//  LZHNetworkHelper.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void  (^LZHNetworkFetcherCompletionHandler)(NSArray *array,NSError *error);
extern NSString *const LZHLOGGINSUCCESSNOTIFICATION;
extern NSString *const LZHNEWMESSAGESNOTIFICATION;
extern NSString *const LZHUSERINFOLOADCOMPLETENOTIFICATION;

@class LZHUser;

@interface LZHNetworkFetcher : NSObject

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password questionId:(NSString *)qid questionAnswer:(NSString *)answer completionHandler:(LZHNetworkFetcherCompletionHandler)completion;
+(void)getUidAndAvatarThenSaveUserName:(NSString *)userName password:(NSString *)password questionId:(NSString *)qid questionAnswer:(NSString *)answer;

+(void)beFriendToUser:(LZHUser *)user withURLString:(NSString *)URLString completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
