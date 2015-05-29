//
//  NSString+LZHHIPDA.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LZHHIPDA)

+(id)encodingGBKString:(NSData *)data;

- (NSString *)md5;

+(NSString *)timeAgo:(NSString *)dateString;

-(id)replacePostContent;

-(NSString *)stringBetweenString:(NSString *)firstString andString:(NSString *)secondString;

-(NSString *)urlEncode;

@end
