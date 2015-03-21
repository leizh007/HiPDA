//
//  NSString+extension.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "NSString+extension.h"

@implementation NSString (extension)

/**
 *  如果字符串为nil，返回@“”，防止用未经初始化的字符串导致程序崩溃
 *
 *  @param string 待检查的字符串
 *
 *  @return 为nil返回@“”，否则返回自己
 */
+(id)ifTheStringIsNilReturnAEmptyString:(NSString *)string{
    if (string!=nil) {
        return string;
    }
    return @"";
}

@end
