//
//  LZHHtmlParser.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHHtmlParser.h"
#import "LZHNotice.h"
#import "LZHThread.h"
#import "LZHUser.h"
#import "NSString+LZHHIPDA.h"
#import "LZHReadList.h"
#import "LZHBlackList.h"
#import "LZHPost.h"
#import "LZHPrompt.h"
#import "JSQMessage.h"

@interface LZHHtmlParser()

@end

@implementation LZHHtmlParser

+(void)extractNoticeFromHtmlString:(NSString *)html{
    NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"私人消息[^(]\\((\\d+)\\)[\\s\\S]*?公共消息[^(]\\((\\d+)\\)[\\s\\S]*?系统消息[^(]\\((\\d+)\\)[\\s\\S]*?好友消息[^(]\\((\\d+)\\)[\\s\\S]*?帖子消息[^(]\\((\\d+)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result=[regex firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
    if (result!=nil) {
        LZHNotice *notice=[LZHNotice sharedNotice];
        notice.promptPm=[[html substringWithRange:[result rangeAtIndex:1]] integerValue];
        notice.promptAnnouncepm=[[html substringWithRange:[result rangeAtIndex:2]] integerValue];
        notice.promptSystemPm=[[html substringWithRange:[result rangeAtIndex:3]] integerValue];
        notice.promptFriend=[[html substringWithRange:[result rangeAtIndex:4]] integerValue];
        notice.promptThreads=[[html substringWithRange:[result rangeAtIndex:5]] integerValue];
        notice.sumPromptPm=notice.promptPm+notice.promptAnnouncepm+notice.promptSystemPm+notice.promptFriend;
        notice.sumPrompt=notice.sumPromptPm+notice.promptThreads;
    }
}

+(void)extractThreadsFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    [LZHHtmlParser extractNoticeFromHtmlString:html];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *threadsString=html;
        NSRange range=[html rangeOfString:@"版块主题"];
        if (range.location!=NSNotFound) {
            threadsString=[html substringFromIndex:range.location];
        }
        NSMutableArray *threads=[[NSMutableArray alloc]init];
        NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"<span[\\s\\S]*?tid=(\\d*)[^>]+>(.*?)</a>([\\s\\S]*?)uid=(\\d+)\">(.*?)</a>[\\s\\S]*?<em>(.*?)</em>[\\s\\S]*?<strong>(.*?)</strong>/<em>(.*?)</em>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches=[regex matchesInString:threadsString options:0 range:NSMakeRange(0, [threadsString length])];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *obj, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSString *tid=[threadsString substringWithRange:[obj rangeAtIndex:1]];
                NSString *title=[threadsString substringWithRange:[obj rangeAtIndex:2]];
                NSString *hasImageOrHasAttach=[threadsString substringWithRange:[obj rangeAtIndex:3]];
                NSString *uid=[threadsString substringWithRange:[obj rangeAtIndex:4]];
                NSString *userName=[threadsString substringWithRange:[obj rangeAtIndex:5]];
                NSString *dateString=[threadsString substringWithRange:[obj rangeAtIndex:6]];
                NSString *replyString=[threadsString substringWithRange:[obj rangeAtIndex:7]];
                NSString *totalString=[threadsString substringWithRange:[obj rangeAtIndex:8]];
                BOOL hasImage=NO;
                BOOL hasAttach=NO;
                if ([hasImageOrHasAttach containsString:@"图片附件"]) {
                    hasImage=YES;
                }else if([hasImageOrHasAttach containsString:@"附件"]){
                    hasAttach=YES;
                }
                LZHUser *user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:uid,
                                                                   LZHUSERUSERNAME:userName}];
                LZHThread *thread=[[LZHThread alloc]initWithUser:user
                                                      replyCount:[replyString integerValue]
                                                      totalCount:[totalString integerValue]
                                                        postTime:dateString
                                                           title:title
                                                             tid:tid
                                                       hasAttach:hasAttach
                                                        hasImage:hasImage
                                                         hasRead:[[LZHReadList sharedReadList] hasReadTid:tid]
                                               isUserInBlackList:[[LZHBlackList sharedBlackList]isUserNameInBlackList:userName]];
                if (!thread.isUserInBlackList) {
                    [threads addObject:thread];
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (threads.count!=0) {
                completion(threads,nil);
            }else{
                completion(nil,[NSError errorWithDomain:@"无法获取帖子列表！" code:0 userInfo:nil]);
            }
        });
    });
}

+(void)extractPostListFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    
    [LZHHtmlParser extractNoticeFromHtmlString:html];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *postList=[[NSMutableArray alloc]init];
        
        //标题
        NSString *title=@"";
        NSRegularExpression *regexTitleWithTags=[NSRegularExpression regularExpressionWithPattern:@"threadtitle\">([\\s\\S]*?)<div\\sclass=\"threadtags\">" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *titleMatchWithTags=[regexTitleWithTags firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        if (titleMatchWithTags!=nil) {
            title=[html substringWithRange:[titleMatchWithTags rangeAtIndex:1]];
        }else{
            NSRegularExpression *regexTitle=[NSRegularExpression regularExpressionWithPattern:@"threadtitle\">([\\s\\S]*?)</div>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult *titleMatch=[regexTitle firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
            if (titleMatch!=nil) {
                title=[html substringWithRange:[titleMatch rangeAtIndex:1]];
            }
        }
        [postList addObject:title];
        
        //总页数
        NSRegularExpression *regexTotalPage=[NSRegularExpression regularExpressionWithPattern:@"(\\d+)</a><a[^>]*?>下一页" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *matchTotlaPage=[regexTotalPage firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSInteger page=1;
        if (matchTotlaPage!=nil ) {
            page=[[html substringWithRange:[matchTotlaPage rangeAtIndex:1]] integerValue];
        }
        [postList addObject:[NSNumber numberWithInteger:page]];
        
        
        //列表
        NSRegularExpression *regexList=[NSRegularExpression regularExpressionWithPattern:@"<div\\sid=\"post_\\d+\">[\\s\\S]*?<td\\sclass=\"postauthor\"[\\s\\S]*?uid=(\\d+)[\\s\\S]*?>([^<]*?)</a>[\\s\\S]*?<em>(\\d+)</em>[\\s\\S]*?<sup>#</sup>[\\s\\S]*?<div\\sclass=\"authorinfo\">[\\s\\S]*?>发表于\\s([\\s\\S]*?)</em>[\\s\\S]*?<div\\sclass=\"t_msgfontfix\">([\\s\\S]*?)</div>[^<]*?<div\\sid=\"post_rate_div_\\d+\"></div>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchesList=[regexList matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        [matchesList enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
            @autoreleasepool {
                NSString *uid=[html substringWithRange:[result rangeAtIndex:1]];
                NSString *userName=[html substringWithRange:[result rangeAtIndex:2]];
                NSInteger floor=[[html substringWithRange:[result rangeAtIndex:3]]integerValue];
                NSString *postTime=[html substringWithRange:[result rangeAtIndex:4]];
                NSString *postMessage=[html substringWithRange:[result rangeAtIndex:5]];
                
                LZHUser *user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:uid,
                                                                   LZHUSERUSERNAME:userName}];
                LZHPost *post=[[LZHPost alloc]init];
                post.user=user;
                post.floor=floor;
                post.postTime=postTime;
                post.postMessage=postMessage;
                post.isBlocked=[[LZHBlackList sharedBlackList]isUserNameInBlackList:userName];
                
                [postList addObject:post];
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                if ([postList count]==2) {
                    completion(nil,[NSError errorWithDomain:@"无法获取帖子内容！" code:0 userInfo:nil]);
                }else{
                    completion(postList,nil);
                }
            }
        });
    });
}

+(void)extractPromptPmFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    [LZHHtmlParser extractNoticeFromHtmlString:html];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"space.php\\?uid=(\\d+)\"\\starget=\"_blank\">(\\w+)</a>[^<]?</cite>([\\s\\S]*?)</p>[^<]+<div\\sclass=\"summary\">([\\s\\S]*?)</div>[\\s\\S]*?<a\\shref=\"([\\s\\S]*?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches=[regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        NSMutableArray *pmArray=[[NSMutableArray alloc]init];
        if (matches.count!=0) {
            [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
                LZHPrompt *prompt=[[LZHPrompt alloc]init];
                LZHUser *user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:[html substringWithRange:[result rangeAtIndex:1]],
                                                                   LZHUSERUSERNAME:[html substringWithRange:[result rangeAtIndex:2]]}];
                prompt.user=user;
                prompt.timeString=[html substringWithRange:[result rangeAtIndex:3]];
                prompt.timeString=[prompt.timeString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
                prompt.titleString=[html substringWithRange:[result rangeAtIndex:4]];
                prompt.titleString=[prompt.titleString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                prompt.titleString=[prompt.titleString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                NSRange imgRange=[prompt.timeString rangeOfString:@"<img"];
                if (imgRange.location!=NSNotFound) {
                    prompt.timeString=[prompt.timeString substringToIndex:imgRange.location];
                    prompt.isNew=YES;
                }else{
                    prompt.isNew=NO;
                }
                prompt.URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[html substringWithRange:[result rangeAtIndex:5]]];
                [pmArray addObject:prompt];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(pmArray,nil);
            }
        });
    });
}

+(void)extractPromptFriendFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    [LZHHtmlParser extractNoticeFromHtmlString:html];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"notice&uid=(\\d+)\">(\\w+)</a>[\\s\\S]*?添加您为好友[\\s\\S]*?<em>([\\s\\S]*?)</em>[\\s\\S]*?href=\"([\\s\\S]*?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches=[regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        NSMutableArray *friendArray=[[NSMutableArray alloc]init];
        if (matches.count!=0) {
            [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
                LZHPrompt *prompt=[[LZHPrompt alloc]init];
                LZHUser *user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:[html substringWithRange:[result rangeAtIndex:1]],
                                                                   LZHUSERUSERNAME:[html substringWithRange:[result rangeAtIndex:2]]}];
                prompt.user=user;
                prompt.timeString=[html substringWithRange:[result rangeAtIndex:3]];
                prompt.titleString=@"请求加您为好友";
                prompt.URLString=[html substringWithRange:[result rangeAtIndex:4]];
                [friendArray addObject:prompt];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(friendArray,nil);
            }
        });
    });
}

/**
 *  获取对话列表
 *
 *  @param html       html
 *  @param completion 返回值：0:参数 1:是否已读 2:对话列表
 */
+(void)extractMessagesFromHtmlString:(NSString *)html completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    [LZHHtmlParser extractNoticeFromHtmlString:html];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messagesArray=[[NSMutableArray alloc] init];
        NSRegularExpression *regexParameters=[NSRegularExpression regularExpressionWithPattern:@"id=\"formhash\"[^v]?value=\"(\\w+)\"[\\s\\S]*?name=\"handlekey\"[^v]?value=\"(\\w+)\"[\\s\\S]*?name=\"lastdaterange\"[^v]?value=\"([\\s\\S]*?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *matchResult=[regexParameters firstMatchInString:html options:0 range:NSMakeRange(0,[html length])];
        if (matchResult==0) {
            if (completion) {
                completion(nil,[NSError errorWithDomain:@"获取参数列表失败！" code:0 userInfo:nil]);
            }
            return ;
        }
        NSDictionary *paramters=@{@"formhash":[html substringWithRange:[matchResult rangeAtIndex:1]],
                                  @"handlekey":[html substringWithRange:[matchResult rangeAtIndex:2]],
                                  @"lastdaterange":[html substringWithRange:[matchResult rangeAtIndex:3]]};
        [messagesArray addObject:paramters];
        NSMutableArray *messages=[[NSMutableArray alloc]init];
        NSMutableArray *isReadArray=[[NSMutableArray alloc]init];
        NSRegularExpression *regexMessages=[NSRegularExpression regularExpressionWithPattern:@"<cite>(\\w+)</cite>([\\s\\S]*?)</p>[\\s\\S]*?\"summary\">([\\s\\S]*?)</div>" options:0 error:nil];
        NSArray *matchesMessages=[regexMessages matchesInString:html options:0 range:NSMakeRange(0, [html length])];
        if ([matchesMessages count]==0) {
            if (completion) {
                completion(nil,[NSError errorWithDomain:@"无法获取对话列表！" code:0 userInfo:nil]);
            }
            return ;
        }
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [matchesMessages enumerateObjectsUsingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
            NSString *userName=[html substringWithRange:[result rangeAtIndex:1]];
            NSString *timeString=[html substringWithRange:[result rangeAtIndex:2]];
            timeString=[timeString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            timeString=[timeString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            timeString=[timeString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if ([timeString containsString:@"<img"]) {
                [isReadArray addObject:@NO];
                timeString=[timeString substringToIndex:[timeString rangeOfString:@"<img"].location];
            }else{
                [isReadArray addObject:@YES];
            }
            NSString *text=[html substringWithRange:[result rangeAtIndex:3]];
            text=[text stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
            NSDate *date=[dateFormatter dateFromString:timeString];
            JSQMessage *message=[[JSQMessage alloc]initWithSenderId:userName
                                                  senderDisplayName:userName
                                                               date:date
                                                               text:text];
            [messages addObject:message];
        }];
        [messagesArray addObject:isReadArray];
        [messagesArray addObject:messages];
        if (completion) {
            completion(messagesArray,nil);
        }
    });
}

@end