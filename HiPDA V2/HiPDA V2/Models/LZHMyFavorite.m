//
//  LZHMyFavorites.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyFavorite.h"
#import "LZHHtmlParser.h"
#import "NSString+LZHHIPDA.h"
#import "LZHHTTPRequestOperationManager.h"

@implementation LZHMyFavorite

+(void)getMyFavoritesInPage:(NSInteger)page completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/my.php?item=favorites&type=thread&page=%ld",page]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractMyFavoritesFromHtmlString:responseString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
