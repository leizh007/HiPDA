//
//  NSString+extension.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "NSString+extension.h"
#import <CommonCrypto/CommonDigest.h>

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

/**
 *  把gbk编码的字符串转化为ios的字符串类型string
 *
 *  @param data gbk编码的数据
 *
 *  @return 转换后的ios字符串类型string
 */
+(id)encodingGBKStringToIOSString:(NSData *)data{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc] initWithData:data encoding:gbkEncoding];
}

/**
 *  得到字符串md5加密后的结果
 *
 *  @return 返回加密后的结果
 */
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
