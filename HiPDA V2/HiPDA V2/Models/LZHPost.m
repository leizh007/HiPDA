//
//  LZHPost.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPost.h"
#import "LZHHTTPRequestOperationManager.h"
#import "LZHHtmlParser.h"
#import "NSString+LZHHIPDA.h"

@interface LZHPost()
@end

@implementation LZHPost

+(void)loadPostTid:(NSString *)tid page:(NSInteger)page completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    NSString *requsetURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/viewthread.php?tid=%@&extra=&page=%ld",tid,page];
    NSDictionary *requsetParameters=@{@"tid":tid,
                                  @"extra":@"",
                                  @"page":[NSString stringWithFormat:@"%ld",page]
                                  };
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:requsetURLString
      parameters:requsetParameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseHtmlstring=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractPostListFromHtmlString:responseHtmlstring completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
