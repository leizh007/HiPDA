//
//  LZHThreadsNotice.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

typedef NS_ENUM(NSInteger, LZHThreadsNoticeType){
    LZHTHreadsNoticeTypeReply,
    LZHTHreadsNoticeTypeQuote
};

@class LZHUser;

@interface LZHThreadsNotice : NSObject

@property (strong, nonatomic) LZHUser  *user;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic  ) NSString *postTime;
@property (copy, nonatomic  ) NSString *myReplyContext;
@property (copy, nonatomic  ) NSString *noticeContext;
@property (assign ,nonatomic) LZHThreadsNoticeType noticeType;
@property (copy, nonatomic) NSString *URLString;

+(void)getThreadsNoticeInPage:(NSInteger)page CompletionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
