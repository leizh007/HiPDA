//
//  LZHSetting.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSetting.h"

@interface LZHSetting()

@end

@implementation LZHSetting

+(id)sharedSetting{
    static LZHSetting *setting=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (setting==nil) {
            setting=[[LZHSetting alloc]init];
        }
    });
    return setting;
}

-(id)init{
    if (self=[super init]) {
        _fontName=@"Helvetica";
    }
    return self;
}
@end
