//
//  LZNotice.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZHNotice : NSObject

+(instancetype)sharedNotice;

@property (assign, nonatomic) NSInteger promptPm;
@property (assign, nonatomic) NSInteger promptAnnouncepm;
@property (assign, nonatomic) NSInteger promptSystemPm;
@property (assign, nonatomic) NSInteger promptFriend;
//帖子总数
@property (assign, nonatomic) NSInteger promptThreads;
//pm总数
@property (assign, nonatomic) NSInteger sumPrompt;
//消息总数，用在threadview里
@property (assign, nonatomic) NSInteger sumPromptPm;

@property (assign, nonatomic) NSInteger myThreads;

@end
