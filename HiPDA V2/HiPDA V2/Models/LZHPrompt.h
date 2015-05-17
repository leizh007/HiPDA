//
//  LZHPromptPm.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/16.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

@class LZHUser;

@interface LZHPrompt : NSObject

@property (strong, nonatomic) LZHUser *user;
@property (copy, nonatomic) NSString *timeString;
@property (copy, nonatomic) NSString *titleString;
@property (copy, nonatomic) NSString *URLString;
@property (assign, nonatomic) BOOL isNew;

+(void)getPmURLString:(NSString *)URLString completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
