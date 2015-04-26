//
//  LZHHTTPRequestOperationManager.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHHTTPRequestOperationManager.h"

@interface LZHHTTPRequestOperationManager()

@end

@implementation LZHHTTPRequestOperationManager

+(id)sharedHTTPRequestOperationManager{
    static LZHHTTPRequestOperationManager *httpRequestOperationManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (httpRequestOperationManager==nil) {
            httpRequestOperationManager=[[LZHHTTPRequestOperationManager alloc]init];
        }
    });
    return httpRequestOperationManager;
}

-(id)init{
    if (self=[super init]) {
        [self.requestSerializer setValue:@"www.hi-pda.com" forHTTPHeaderField:@"Host"];
        [self.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.91 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
        [self.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        [self.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language" ];
        [self.requestSerializer setValue:@"http://www.hi-pda.com/forum/forumdisplay.php?fid=2" forHTTPHeaderField:@"Referer"];
        self.responseSerializer=[AFHTTPResponseSerializer serializer];
        self.requestSerializer=[AFHTTPRequestSerializer serializer];
        self.requestSerializer.stringEncoding=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    return self;
}

@end
