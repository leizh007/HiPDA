//
//  LZHThreadsNotice.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHThreadNotice.h"
#import "LZHHTTPRequestOperationManager.h"
#import "LZHHtmlParser.h"
#import "NSString+LZHHIPDA.h"

@interface LZHThreadNotice()

@end

@implementation LZHThreadNotice

+(void)getThreadsNoticeInPage:(NSInteger)page CompletionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/notice.php?filter=threads&page=%ld",page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractThreadsNoticeFromHtmlString:responseString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
