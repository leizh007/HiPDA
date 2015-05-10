//
//  LZHNetworkHelper.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHNetworkFetcher.h"
#import "LZHHTTPRequestOperationManager.h"
#import "NSString+LZHHIPDA.h"
#import "MTLog.h"
#import "LZHShowMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZHAccount.h"
#import "LZHHtmlParser.h"

NSString *const LZHLOGGINSUCCESSNOTIFICATION=@"LZHLOGGINSUCCESSNOTIFICATION";
NSString *const LZHNEWMESSAGESNOTIFICATION=@"LZHNEWMESSAGESNOTIFICATION";
NSString *const LZHUSERINFOLOADCOMPLETENOTIFICATION=@"LZHUSERINFOLOADCOMPLETENOTIFICATION";

@interface LZHNetworkFetcher()

@end

@implementation LZHNetworkFetcher

+(void)loginWithUserName:(NSString *)userName password:(NSString *)password questionId:(NSString *)qid questionAnswer:(NSString *)answer completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    [LZHNetworkFetcher formHashInHtmlFromUrlString:@"http://www.hi-pda.com/forum/logging.php?action=login"
                                 completionHandler:^(NSArray *array, NSError *error) {
                                     if (error!=nil) {
                                         completion(nil,error);
                                     }else{
                                         NSDictionary *params=@{@"loginfield":@"username",
                                                                @"username":userName,
                                                                @"password":password,
                                                                @"questionid":qid,
                                                                @"answer":answer,
                                                                @"formhash":array[0],
                                                                @"cookietime":@"2592000",
                                                                @"Referer":@"http://www.hi-pda.com/forum/index.php"};
                                         LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
                                         [manager POST:@"http://www.hi-pda.com/forum/logging.php?action=login&loginsubmit=yes&inajax=1"
                                            parameters:params
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSString *responseString=[NSString encodingGBKString:responseObject];
                                                   if ([responseString containsString:@"欢迎您回来"]) {
                                                       completion(nil,nil);
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:LZHLOGGINSUCCESSNOTIFICATION object:nil userInfo:nil];
                                                   }else{
                                                       NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"登录失败，您还可以尝试\\s\\d\\s次" options:NSRegularExpressionCaseInsensitive error:nil];
                                                       NSArray *matches=[regex matchesInString:responseString options:0 range:NSMakeRange(0, [responseString length])];
                                                       if ([matches count]==0) {
                                                           completion(nil,[NSError errorWithDomain:responseString code:0 userInfo:nil]);
                                                       }else{
                                                           completion(nil,[NSError errorWithDomain:[responseString substringWithRange:[((NSTextCheckingResult *)matches[0]) rangeAtIndex:0]] code:0 userInfo:nil]);
                                                       }
                                                   }
                                                   
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   completion(nil,error);
                                               }];
                                     }
                                 }];
    
}


+(void)formHashInHtmlFromUrlString:(NSString *)url completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager POST:@"http://www.hi-pda.com/forum/logging.php?action=login"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *responseString=[NSString encodingGBKString:responseObject];
              NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"formhash=(\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
              NSArray *matches=[regex matchesInString:responseString options:0 range:NSMakeRange(0, [responseString length])];
              if ([matches count]==0) {
                  completion(nil,[NSError errorWithDomain:@"获取formhash失败！" code:0 userInfo:nil]);
              }else{
                  NSString *formhash=[responseString substringWithRange:[((NSTextCheckingResult *)matches[0]) rangeAtIndex:1]];
                  completion(@[formhash],nil);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completion(nil,error);
          }];
}

+(void)getUidAndAvatarThenSaveUserName:(NSString *)userName password:(NSString *)password questionId:(NSString *)qid questionAnswer:(NSString *)answer{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    [manager GET:@"http://www.hi-pda.com/forum/index.php"
      parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *resposeString=[NSString encodingGBKString:responseObject];
          NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"space.php\\?uid=(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil];
          NSArray *matches=[regex matchesInString:resposeString options:0 range:NSMakeRange(0, [resposeString length])];
          if ([matches count]==0) {
              [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"无法获取UID!"];
          }else{
              NSString *uid=[resposeString substringWithRange:[(NSTextCheckingResult *)matches[0] rangeAtIndex:1]];
              NSInteger uidInteger=[uid integerValue];
              NSString *avatarStringUrl=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg",uidInteger/1000000,(uidInteger%1000000)/10000,(uidInteger%10000)/100,uidInteger%100];
              SDWebImageManager *imageManager=[SDWebImageManager sharedManager];
              [imageManager downloadImageWithURL:[NSURL URLWithString:avatarStringUrl]
                                         options:0
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            
                                        }
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                           if (error==nil) {
                                               [[LZHAccount sharedAccount] setAccount:@{LZHACCOUNTUSERNAME:userName,
                                                                                        LZHACCOUNTUSERPASSWORDD:password,
                                                                                        LZHACCOUNTQUESTIONID:qid,
                                                                                        LZHACCOUNTQUESTIONANSWER:answer,
                                                                                        LZHACCOUNTUSERUID:uid,
                                                                                        LZHACCOUNTUSERAVATAR:image}];
                                           }else{
                                               [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                                           }
                                           
                                       }];
          }
      }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
         }];
}


@end
