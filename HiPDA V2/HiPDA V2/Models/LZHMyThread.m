//
//  LZHMyThreads.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyThread.h"
#import "LZHHTTPRequestOperationManager.h"
#import "LZHHtmlParser.h"
#import "NSString+LZHHIPDA.h"

@interface LZHMyThread()

@end

@implementation LZHMyThread

+(void)getMyThreadsInPage:(NSInteger)page completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/my.php?item=threads&page=%ld",page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractMyThreadsFromHtmlString:responseString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
