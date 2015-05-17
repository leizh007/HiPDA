//
//  LZNotice.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHNotice.h"

@interface LZHNotice()

@end

@implementation LZHNotice

+(instancetype)sharedNotice{
    static LZHNotice *notice=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notice=[[LZHNotice alloc]init];
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
