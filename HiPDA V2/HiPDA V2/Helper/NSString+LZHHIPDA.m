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
    NSDate *date=[dateFormatter dateFromString:dateString];
    
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

-(id)replacePostContent{
    NSString *postMessage=[self copy];
    //替换视频地址
    NSRegularExpression *regexVedio=[NSRegularExpression regularExpressionWithPattern:@"<script\\stype=\"text/javascript\"[\\s\\S]*?(http://[\\s\\S]*?)'[\\s\\S]*?</script>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matchesVedio=[regexVedio matchesInString:self options:0 range:NSMakeRange(0, [postMessage length])];
    if ([matchesVedio count]!=0) {
        NSMutableArray *fullVedioContentArray=[[NSMutableArray alloc]init];
        NSMutableArray *vedioLinkArray=[[NSMutableArray alloc]init];
        [matchesVedio enumerateObjectsUsingBlock:^(NSTextCheckingResult *vedioResult, NSUInteger idx, BOOL *stop) {
            [fullVedioContentArray addObject:[postMessage substringWithRange:[vedioResult rangeAtIndex:0]]];
            [vedioLinkArray addObject:[postMessage substringWithRange:[vedioResult rangeAtIndex:1]]];
        }];
        for (int i=0; i<[fullVedioContentArray count]; ++i) {
            NSString *vedioLink=[NSString stringWithFormat:@"<a class=\"vedio\" href=\"%@\">%@</a>",vedioLinkArray[i],vedioLinkArray[i]];
            postMessage=[postMessage stringByReplacingOccurrencesOfString:fullVedioContentArray[i] withString:vedioLink];
        }
    }
    
    //用附件列表里的图片替换附件列表里的内容
    NSRegularExpression *regexAttachment=[NSRegularExpression regularExpressionWithPattern:@"<dl\\sclass=\"t_attachlist\\sattachimg\">[\\s\\S]*?<img\\ssrc=[\\s\\S]*?file=\"([\\s\\S]*?)\"[\\s\\S]*?</dl>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matchesAttachment=[regexAttachment matchesInString:postMessage options:0 range:NSMakeRange(0, [postMessage length])];
    if ([matchesAttachment count]!=0) {
        NSMutableArray *fullAttachmentContentArray=[[NSMutableArray alloc]init];
        NSMutableArray *imgLinkArray=[[NSMutableArray alloc]init];
        [matchesAttachment enumerateObjectsUsingBlock:^(NSTextCheckingResult *attchmentResult, NSUInteger idx, BOOL *stop) {
            [fullAttachmentContentArray addObject:[postMessage substringWithRange:[attchmentResult rangeAtIndex:0]]];
            [imgLinkArray addObject:[postMessage substringWithRange:[attchmentResult rangeAtIndex:1]]];
        }];
        for (int i=0; i<[fullAttachmentContentArray count]; ++i) {
            NSString *img=[NSString stringWithFormat:@"<img class=\"attahmentImage\" src=\"%@\"></img>",imgLinkArray[i]];
            postMessage=[postMessage stringByReplacingOccurrencesOfString:fullAttachmentContentArray[i] withString:img];
        }
    }
    
    //替换图片地址
    NSRegularExpression *regexImage=[NSRegularExpression regularExpressionWithPattern:@"<img\\ssrc=\"([^\\\"]*)\"\\sfile=\"([^\\\"]*)\"" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matchesImage=[regexImage matchesInString:postMessage options:0 range:NSMakeRange(0, [postMessage length])];
    if ([matchesImage count]!=0) {
        NSMutableArray *fullImageArray=[[NSMutableArray alloc]init];
        NSMutableArray *imgFileArray=[[NSMutableArray alloc]init];
        [matchesImage enumerateObjectsUsingBlock:^(NSTextCheckingResult *imageResult, NSUInteger idx, BOOL *stop) {
            [fullImageArray addObject:[postMessage substringWithRange:[imageResult rangeAtIndex:1]]];
            [imgFileArray addObject:[postMessage substringWithRange:[imageResult rangeAtIndex:2]]];
        }];
        for (int i=0; i<[fullImageArray count]; ++i) {
            postMessage=[postMessage stringByReplacingOccurrencesOfString:fullImageArray[i] withString:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",imgFileArray[i]]];
        }
    }
    
    return postMessage;
}

-(NSString *)stringBetweenString:(NSString *)firstString andString:(NSString *)secondString{
    NSRange rangeFirst=[self rangeOfString:firstString];
    if (rangeFirst.location==NSNotFound) {
        return @"";
    }
    NSString *stringBehindFirstString=[self substringFromIndex:rangeFirst.location+rangeFirst.length];
    NSRange rangeSecond=[stringBehindFirstString rangeOfString:secondString];
    if (rangeSecond.location==NSNotFound) {
        return @"";
    }
    return [stringBehindFirstString substringToIndex:rangeSecond.location];
}

-(NSString*)urlEncode{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               kCFStringEncodingGB_18030_2000));
}

@end
