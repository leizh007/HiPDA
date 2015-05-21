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
#import "NSString+LZHHIPDA.h"

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

+(void)sendPmToUser:(LZHUser *)user
            message:(NSString *)message
  completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/pm.php?action=new&uid=%@",user.uid]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             NSString *formhash=[responseString stringBetweenString:@"formhash=" andString:@"\""];
             if ([formhash isEqualToString:@""]) {
                 if (completion) {
                     completion(nil,[NSError errorWithDomain:@"无法获取formhash" code:0 userInfo:nil]);
                 }
             }else{
                 NSDictionary *parameters=@{@"formhash":formhash,
                                            @"msgto":user.userName,
                                            @"message":message,
                                            @"pmsubmit":@YES};
                 [manager POST:@"http://www.hi-pda.com/forum/pm.php?action=send&pmsubmit=yes&infloat=yes&sendnew=yes"
                    parameters:parameters
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           NSString *responseFromSendPmString=[NSString encodingGBKString:responseObject];
                           if (completion) {
                               if ([responseFromSendPmString containsString:@"短消息发送成功。"]) {
                                   completion(@[@"短消息发送成功。"],nil);
                               }else{
                                   completion(nil,[NSError errorWithDomain:responseFromSendPmString code:0 userInfo:nil]);
                               }
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           if (completion) {
                               completion(nil,error);
                           }
                       }];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

+(void)addFriend:(LZHUser *)user completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:[NSString stringWithFormat:@"http://www.hi-pda.com/forum/my.php?item=buddylist&newbuddyid=%@&buddysubmit=yes&inajax=1&ajaxtarget=addbuddy_menu_content",user.uid]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             NSString *responseMessage=[responseString stringBetweenString:@"<![CDATA[" andString:@"]]>"];
             if (completion) {
                 if ([responseMessage isEqualToString:@""]) {
                     completion(nil,[NSError errorWithDomain:@"无法获取返回信息！" code:0 userInfo:nil]);
                 }else{
                     completion(@[responseMessage],nil);
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