//
//  LZHSearchResult.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/29.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSearchResult.h"
#import "LZHHTTPRequestOperationManager.h"
#import "NSString+LZHHIPDA.h"
#import "LZHHtmlParser.h"

@implementation LZHSearchResult

+(void)getSearchResultInURLString:(NSString *)URLString completionHanlder:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:URLString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractSearchResultsFromHtmlString:responseString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
