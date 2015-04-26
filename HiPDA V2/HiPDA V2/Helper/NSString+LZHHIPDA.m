//
//  NSString+LZHHIPDA.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "NSString+LZHHIPDA.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (LZHHIPDA)

+(id)encodingGBKString:(NSData *)data{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc] initWithData:data encoding:gbkEncoding];
}

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

+(NSString *)timeAgo:(NSString *)dateString
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[[NSDate alloc]init];
    date=[dateFormatter dateFromString:dateString];
    
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaMinutes < (24 * 60))
    {
        return @"今天";
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return @"昨天";
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:@"%d天前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return @"上周";
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:@"%d周前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return @"上个月";
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:@"%d月前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return @"去年";
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [NSString stringWithFormat:@"%d年前",minutes];
}

@end
