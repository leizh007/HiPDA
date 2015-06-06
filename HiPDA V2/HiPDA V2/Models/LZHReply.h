//
//  LZHReply.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/18.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"
#import "LZHReplyViewController.h"

@class LZHUser;

@interface LZHReply : NSObject

+(void)replyPrivatePmToUser:(LZHUser *)user
               withFormhash:(NSString *)formhash
                  handlekey:(NSString *)handlekey
              lastdaterange:(NSString *)lastdaterange
                    message:(NSString *)message
          completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)sendPmToUser:(LZHUser *)user
            message:(NSString *)message
  completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)addFriend:(LZHUser *)user completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)uploadImage:(NSData *)data completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

+(void)replyType:(LZHReplyType)replyType parameters:(NSDictionary *)parameters completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
