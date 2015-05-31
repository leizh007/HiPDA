//
//  LZHPost.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

@class LZHUser;

@interface LZHPost : NSObject

@property (copy, nonatomic) NSString *pid;
@property (strong, nonatomic) LZHUser *user;
@property (strong, nonatomic) NSString *postTime;
@property (assign, nonatomic) NSInteger floor;
@property (strong, nonatomic) NSString *postMessage;
@property (assign, nonatomic) BOOL isBlocked;

+(void)loadPostTid:(NSString *)tid page:(NSInteger)page fullURLString:(NSString *)URLString completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
