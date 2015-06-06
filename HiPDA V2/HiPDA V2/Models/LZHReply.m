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
#import "AFURLSessionManager.h"
#import "LZHAccount.h"
#import "LZHNetworkFetcher.h"

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

+(void)uploadImage:(NSData *)data completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    static NSInteger imageIndex=1;
    [LZHNetworkFetcher getParametersFromURLString:@"http://www.hi-pda.com/forum/post.php?action=newthread&fid=57" completionHandler:^(NSArray *array, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil,error);
            }
        }else{
            NSDictionary *parameters=array[0];
            NSString *hash=parameters[@"hash"];
            LZHHTTPRequestOperationManager *manager = [LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
            [manager POST:@"http://www.hi-pda.com/forum/misc.php?type=image&action=swfupload&operation=upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                LZHAccount *account=[LZHAccount sharedAccount];
                NSDictionary *accountInfo=[account account];
                NSString *uid=accountInfo[LZHACCOUNTUSERUID];
                //NSLog(@"uid %@ hash %@",uid,hash);
                [formData appendPartWithFormData:[uid dataUsingEncoding:NSUTF8StringEncoding] name:@"uid"];
                [formData appendPartWithFormData:[hash dataUsingEncoding:NSUTF8StringEncoding] name:@"hash"];
                [formData appendPartWithFileData:data name:@"Filedata" fileName:[NSString stringWithFormat:@"hper_%ld.jpeg",imageIndex++] mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseString=[NSString encodingGBKString:responseObject];
                if (completion) {
                    completion(@[responseString],nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (completion) {
                    completion(nil,error);
                }
            }];

        }
    }];
}

+(void)replyType:(LZHReplyType)replyType parameters:(NSDictionary *)parameters completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    NSString *parametersURLString;
    switch (replyType) {
        case LZHReplyTypeNewTopic: {
            parametersURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=newthread&fid=%@",parameters[@"fid"]];
            break;
        }
        case LZHreplyTypeNewPost: {
            parametersURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@",parameters[@"fid"],parameters[@"tid"]];
            break;
        }
        case LZHReplyTypeReply: {
            NSNumber *page=parameters[@"page"];
            parametersURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@&reppost=%@&extra=page%%3D1&page=%ld",parameters[@"fid"],parameters[@"tid"],parameters[@"pid"],[page integerValue]];
            break;
        }
        case LZHReplyTypeQuote: {
            NSNumber *page=parameters[@"page"];
            parametersURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@&repquote=%@&extra=page%%3D1&page=%ld",parameters[@"fid"],parameters[@"tid"],parameters[@"pid"],[page integerValue]];
            break;
        }
        default: {
            break;
        }
    }
    
    [LZHNetworkFetcher getParametersFromURLString:parametersURLString completionHandler:^(NSArray *array, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil,error);
            }
        }else{
            NSDictionary *requestFromDataParameters=(NSDictionary *)array[0];
            NSString *URLString;
            NSMutableDictionary *requestFullParamters;
            NSDictionary *requstFormData;
            switch (replyType) {
                case LZHReplyTypeNewTopic: {
                    URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=newthread&fid=%@&extra=&topicsubmit=yes",parameters[@"fid"]];
                    requstFormData=@{@"formhash":requestFromDataParameters[@"formhash"],
                                                   @"posttime":requestFromDataParameters[@"posttime"],
                                                   @"wysiwyg":requestFromDataParameters[@"wysiwyg"],
                                                   @"iconid":@"",
                                                   @"subject":parameters[@"subject"],
                                                   @"typeid":parameters[@"typeid"],
                                                   @"message":parameters[@"message"],
                                                   @"tags":@"",
                                                   @"attention_add":@"1"};
                    

                    break;
                }
                case LZHreplyTypeNewPost: {
                    URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@&extra=&replysubmit=yes",parameters[@"fid"],parameters[@"tid"]];
                    requstFormData=@{@"formhash":requestFromDataParameters[@"formhash"],
                                     @"posttime":requestFromDataParameters[@"posttime"],
                                     @"wysiwyg":requestFromDataParameters[@"wysiwyg"],
                                     @"noticeauthor":@"",
                                     @"noticetrimstr":@"",
                                     @"noticeauthormsg":@"",
                                     @"subject":@"",
                                     @"message":parameters[@"message"]
                                     };
                    break;
                }
                case LZHReplyTypeReply: {
                    URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@&extra=page%%3D1&replysubmit=yes",parameters[@"fid"],parameters[@"tid"]];
                    requstFormData=@{@"formhash":requestFromDataParameters[@"formhash"],
                                     @"posttime":requestFromDataParameters[@"posttime"],
                                     @"wysiwyg":requestFromDataParameters[@"wysiwyg"],
                                     @"noticeauthor":requestFromDataParameters[@"noticeauthor"],
                                     @"noticetrimstr":requestFromDataParameters[@"noticetrimstr"],
                                     @"noticeauthormsg":requestFromDataParameters[@"noticeauthormsg"],
                                     @"subject":@"",
                                     @"message":[NSString stringWithFormat:@"%@\n%@",requestFromDataParameters[@"noticetrimstr"],parameters[@"message"]]
                                     };
                    break;
                }
                case LZHReplyTypeQuote: {
                    URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/post.php?action=reply&fid=%@&tid=%@&extra=page%%3D1&replysubmit=yes",parameters[@"fid"],parameters[@"tid"]];
                    requstFormData=@{@"formhash":requestFromDataParameters[@"formhash"],
                                     @"posttime":requestFromDataParameters[@"posttime"],
                                     @"wysiwyg":requestFromDataParameters[@"wysiwyg"],
                                     @"noticeauthor":requestFromDataParameters[@"noticeauthor"],
                                     @"noticetrimstr":requestFromDataParameters[@"noticetrimstr"],
                                     @"noticeauthormsg":requestFromDataParameters[@"noticeauthormsg"],
                                     @"subject":@"",
                                     @"message":[NSString stringWithFormat:@"%@\n\t%@\n%@",requestFromDataParameters[@"noticetrimstr"],requestFromDataParameters[@"noticeauthormsg"],parameters[@"message"]]
                                     };
                    break;
                }
                default: {
                    break;
                }
            }
        
            requestFullParamters=[[NSMutableDictionary alloc]initWithDictionary:requstFormData];
            NSArray *imageResponse=parameters[@"image"];
            [imageResponse enumerateObjectsUsingBlock:^(NSString *res, NSUInteger idx, BOOL *stop) {
                [requestFullParamters setValue:@"" forKey:[NSString stringWithFormat:@"attachnew[%@][description]:",res]];
            }];
            
            LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
            [manager POST:URLString parameters:requestFullParamters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseString=[NSString encodingGBKString:responseObject];
                if (completion){
                    if ([responseString containsString:@"对不起，您两次发表间隔少于 30 秒，请不要灌水！"]) {
                        completion(nil,[NSError errorWithDomain:@"对不起，您两次发表间隔少于 30 秒，请不要灌水！" code:0 userInfo:nil]);
                    }else{
                        completion(nil,nil);
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (completion) {
                    completion(nil,error);
                }
            }];
        }
    }];
}

@end