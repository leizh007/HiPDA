//
//  LZNotice.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZNotice : NSObject

+(id)shareNotice;

@property (assign, nonatomic) NSInteger promptPm;
@property (assign, nonatomic) NSInteger promptAnnouncepm;
@property (assign, nonatomic) NSInteger promptSystemPm;
@property (assign, nonatomic) NSInteger promptFriend;
@property (assign, nonatomic) NSInteger promptThreads;
@property (assign, nonatomic) NSInteger sumPrompt;
@property (assign, nonatomic) NSInteger sumPromptPm;

@end
