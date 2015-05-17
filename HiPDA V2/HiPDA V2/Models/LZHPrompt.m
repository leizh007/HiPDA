//
//  LZHPromptPm.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/16.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPrompt.h"
#import "LZHHTTPRequestOperationManager.h"
#import "LZHHtmlParser.h"
#import "NSString+LZHHIPDA.h"

@implementation LZHPrompt

+(void)getPmURLString:(NSString *)URLString completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:URLString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseHtmlstring=[NSString encodingGBKString:responseObject];
             if (completion) {
                 if ([URLString containsString:@"privatepm"]) {
                     [LZHHtmlParser extractPromptPmFromHtmlString:responseHtmlstring completionHandler:completion];
                 }else if([URLString containsString:@"friend"]){
                     [LZHHtmlParser extractPromptFriendFromHtmlString:responseHtmlstring completionHandler:completion];
                 }else{
                     if (completion) {
                         completion([[NSArray alloc]init],nil);
                     }
                 }
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
