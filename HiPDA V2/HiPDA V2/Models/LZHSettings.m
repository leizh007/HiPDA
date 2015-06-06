//
//  LZHSetting.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSettings.h"

@interface LZHSettings()

@end

@implementation LZHSettings

+(id)sharedSetting{
    static LZHSettings *setting=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (setting==nil) {
            setting=[[LZHSettings alloc]init];
        }
    });
    return setting;
}

-(id)init{
    if (self=[super init]) {
        _fontName=@"Helvetica";
        _tail=@"[size=1][url=http://www.hi-pda.com/forum/viewthread.php?tid=1598240]人家是超级大丁丁[/url][/size]";
    }
    return self;
}
@end
