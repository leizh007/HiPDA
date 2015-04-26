//
//  LZThread.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LZHUser;

@interface LZHThread : NSObject

@property (strong, nonatomic) LZHUser *user;
@property (assign, nonatomic) NSInteger replyCount;
@property (assign, nonatomic) NSInteger totalCount;
@property (strong, nonatomic) NSString *postTime;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *tid;
@property (assign, nonatomic) BOOL hasAttach;
@property (assign, nonatomic) BOOL hasImage;
@property (assign, nonatomic) BOOL hasRead;
@property (assign, nonatomic) BOOL isUserInBlackList;

//postTime为原始数据，比如2015-4-26，转化为距离今天的时间
-(id)initWithUser:(LZHUser *)user replyCount:(NSInteger)replyCount totalCount:(NSInteger)totalCount postTime:(NSString *)postTime title:(NSString *)title tid:(NSString *)tid hasAttach:(BOOL)hasAttach hasImage:(BOOL)hasImage;

@end
