//
//  NSString+HiPDA.m
//  HiPDA
//
//  Created by leizh007 on 2017/3/20.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

#import "NSString+HiPDA.h"

@implementation NSString (HiPDA)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (nullable NSString *)gbkEscaped {
    // http://www.cnblogs.com/meyers/archive/2012/04/26/2471669.html
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)self,
                                                                                 NULL,
                                                                                 CFSTR(":/?#[]@!$&’()*+,;="),
                                                                                 kCFStringEncodingGB_18030_2000);
}
#pragma clang diagnostic pop


@end
