//
//  LZNotice.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZNotice.h"

@interface LZNotice()

@end

@implementation LZNotice

+(id)shareNotice{
    static LZNotice *notice=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notice=[[LZNotice alloc]init];
    });
    return notice;
}

-(id)init{
    self=[super init];
    if (self) {
        _promptPm=0;
        _promptAnnouncepm=0;
        _promptSystemPm=0;
        _promptFriend=0;
        _promptFriend=0;
        _sumPrompt=0;
    }
    return self;
}

@end
