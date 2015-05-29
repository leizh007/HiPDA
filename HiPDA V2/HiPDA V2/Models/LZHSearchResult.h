//
//  LZHSearchResult.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/29.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

typedef NS_ENUM(NSInteger, LZHSearchResultThreadAttachType){
    LZHSearchResultThreadAttachTypeImage,
    LZHSearchResultThreadAttachTypeAttach,
    LZHSearchResultThreadAttachTypeNone
};

@class LZHUser;

@interface LZHSearchResult : NSObject

@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) LZHSearchResultThreadAttachType searchResultThreadAttachType;
@property (copy, nonatomic) NSString *fidName;
@property (strong, nonatomic) LZHUser *uesr;
@property (copy, nonatomic) NSString *postTime;
@property (copy, nonatomic) NSString *replyCount;
@property (copy, nonatomic) NSString *openCount;
@property (copy, nonatomic) NSAttributedString *attributedTitle;

+(void)getSearchResultInURLString:(NSString *)URLString completionHanlder:(LZHNetworkFetcherCompletionHandler)completion;

@end
