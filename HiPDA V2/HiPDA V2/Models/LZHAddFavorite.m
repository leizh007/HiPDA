//
//  LZHAddFavorite.m
//  HiPDA V2
//
//  Created by leizh007 on 15/6/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHAddFavorite.h"
#import "NSString+LZHHIPDA.h"
#import "LZHHTTPRequestOperationManager.h"

@implementation LZHAddFavorite

+(void)addFavoriteTid:(NSString *)tid completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/my.php?item=favorites&tid=%@&inajax=1&ajaxtarget=favorite_msg",tid]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             NSString *replyString=[responseString stringBetweenString:@"CDATA[" andString:@"<br"];
             if (completion) {
                 completion(@[replyString],nil);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
