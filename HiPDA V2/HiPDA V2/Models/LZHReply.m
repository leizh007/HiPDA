//
//  LZHReply.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/18.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHReply.h"
#import "LZHUser.h"
#import "LZHHTTPRequestOperationManager.h"

@implementation LZHReply

+(void)replyPrivatePmToUser:(LZHUser *)user
               withFormhash:(NSString *)formhash
                  handlekey:(NSString *)handlekey
              lastdaterange:(NSString *)lastdaterange
                    message:(NSString *)message
          completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    NSString *URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/pm.php?action=send&uid=%@&pmsubmit=yes&infloat=yes&inajax=1",user.uid];
    NSDictionary *parameters=@{@"formhash":formhash,
                               @"handlekey":handlekey,
                               @"lastdaterange":lastdaterange,
                               @"message":message};
    [manager POST:URLString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completion) {
                  completion(nil,error);
              }
          }];
}

@end