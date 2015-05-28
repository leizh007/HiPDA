//
//  LZHHtmlParser.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

@interface LZHHtmlParser : NSObject

+(void)extractNoticeFromHtmlString:(NSString *)html;

+(void)extractThreadsFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractPostListFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractPromptPmFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractPromptFriendFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractMessagesFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractThreadsNoticeFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractMyThreadsFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractMyPostsFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)extractMyFavoritesFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
