//
//  LZThreadDetail.h
//  HiPDA
//
//  Created by leizh007 on 15/3/31.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZUser.h"

@interface LZThreadDetail : NSObject

@property (strong, nonatomic) LZUser *user;
@property (assign, nonatomic) BOOL hasReply;
@property (strong, nonatomic) NSString *replyString;
@property (assign, nonatomic) BOOL hasQuote;
@property (strong, nonatomic) NSString *quoteString;
//帖子内容数组
@property (strong, nonatomic) NSArray *contextArray;
//帖子楼层，0层是主贴，其他是回复1楼到n楼
@property (assign, nonatomic) NSInteger postnum;
//帖子内容原始版
@property (strong, nonatomic) NSString *rawContext;

@property (strong, nonatomic) NSString *time;

@property (strong, nonatomic) NSString *pid;

@end
