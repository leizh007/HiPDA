//
//  LZNetworkHelper.m
//  HiPDA
//
//  Created by leizh007 on 15/3/22.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZNetworkHelper.h"
#import "SVProgressHUD.h"
#import "NSString+extension.h"
#import "LZThread.h"
#import "LZUser.h"
#import "LZPersistenceDataManager.h"
#import "LZCache.h"
#import "LZAccount.h"
#import "TFHpple.h"
#import "LZThreadDetail.h"

@interface LZNetworkHelper()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation LZNetworkHelper

+(id)sharedLZNetworkHelper{
    static LZNetworkHelper *networkHelper=nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        networkHelper=[[LZNetworkHelper alloc]init];
    });
    return networkHelper;
}

/**
 *  初始化AFHTTPRequestOperationManager，设置请求头
 *
 *  @return 自己
 */
-(id)init{
    self=[super init];
    self.manager=[AFHTTPRequestOperationManager manager];
    [self.manager.requestSerializer setValue:@"www.hi-pda.com" forHTTPHeaderField:@"Host"];
    [self.manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.91 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.manager.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self.manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language" ];
    [self.manager.requestSerializer setValue:@"http://www.hi-pda.com/forum/forumdisplay.php?fid=2" forHTTPHeaderField:@"Referer"];
    self.manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    return self;
}


/**
 *  登录
 *
 *  @param parameters 用户名，密码，安全问题，回答
 *  @param block      回调块
 */
-(void)login:(NSDictionary *)parameters block:(void (^)(BOOL, NSError *))block{
    [self.manager GET:@"http://www.hi-pda.com/forum/logging.php?action=login"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSString *responHtml=[NSString ifTheStringIsNilReturnAEmptyString:[NSString encodingGBKStringToIOSString:responseObject]];
//                  NSLog(@"%@",responHtml);
                  if ([responHtml containsString:@"欢迎您回来"]) {
                      block(YES,nil);
                      return ;
                  }
                  NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"(?<=formhash\" value=\")\\w+\\b" options:NSRegularExpressionCaseInsensitive error:nil];
                  NSArray *matches=[regex matchesInString:responHtml options:0 range:NSMakeRange(0, [responHtml length])];
                  if ([matches count]==0) {
                      block(NO,nil);
                      return;
                  }
                  NSString *formhash=[responHtml substringWithRange:((NSTextCheckingResult *)matches[0]).range];
//                  NSLog(@"%@",formhash);
                  NSMutableDictionary *param=[NSMutableDictionary dictionaryWithDictionary:parameters];
                  [param setValue:formhash forKey:@"formhash"];
                  [self.manager POST:@"http://www.hi-pda.com/forum/logging.php?action=login&loginsubmit=yes&inajax=1"
                          parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSString *responString=[NSString encodingGBKStringToIOSString:responseObject];
//                              NSLog(@"%@",responString);
                              if ([responString containsString:@"欢迎您回来"]) {
                                  //获得用户的uid
                                  [self.manager GET:@"http://www.hi-pda.com/forum/index.php"
                                         parameters:nil
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                NSString *responString=[NSString encodingGBKStringToIOSString:responseObject];
                                                NSRange range=[responString rangeOfString:@"space.php?uid="];
                                                if (range.location!=NSNotFound) {
                                                    responString=[responString substringFromIndex:range.location+range.length];
                                                    range=[responString rangeOfString:@"\""];
                                                    NSString *uid=[responString substringWithRange:NSMakeRange(0, range.location)];
                                                    [[LZAccount sharedAccount] setAccountUid:uid];
                                                }
                                                block(YES,nil);
                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                
                                            }];
                              }else{
                                  block(NO,nil);
                              }
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              block(NO,error);
                          }];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  block(NO,error);
              }];
}

/**
 *  加载论坛帖子列表
 *
 *  @param fid     论坛版块fid
 *  @param page    页数
 *  @param success 加载成功调用block
 *  @param failure 加载失败调用block
 */
-(void)loadForumFid:(NSInteger)fid page:(NSInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSString *forumURL=[NSString stringWithFormat:@"%@%ld&page=%ld",FORUMSECTIONBASEADDRESS,(long)fid,(long)page];
    NSDictionary *param=@{@"fid":[NSNumber numberWithInteger:fid],
                          @"page":[NSNumber numberWithInteger:page]};
    [[NSNotificationCenter defaultCenter]postNotificationName:FORUMTHREADSISGETTINGNOTIFICATION object:nil];
    [self.manager GET:forumURL
           parameters:param
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSString *responseHtml=[NSString ifTheStringIsNilReturnAEmptyString:[NSString encodingGBKStringToIOSString:responseObject]];
//                  NSLog(@"%@",responseHtml);
                  [[NSNotificationCenter defaultCenter]postNotificationName:FORUMTHREADSISEXTRACTINGNOTIFICATION object:nil];
                  NSRange range=[responseHtml rangeOfString:@"版块主题"];
                  if (range.location!=NSNotFound) {
                      responseHtml=[responseHtml substringFromIndex:range.location];
                  }
                  
//                  NSLog(@"%@",responseHtml);
                  NSArray *threads=[self extractThreadsFromHtmlString:responseHtml fid:fid page:page];
                  if (page==1) {
                      [[LZCache globalCache]cacheForum:threads fid:fid page:page];
                  }
                  success(threads);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
}

/**
 *  从html代码中把帖子列表抽取出来
 *
 *  @param html html源代码
 *
 *  @return 返回帖子列表
 */
-(id)extractThreadsFromHtmlString:(NSString *)html fid:(NSInteger )fid page:(NSInteger) page{
    NSMutableArray *threads=[[NSMutableArray alloc]init];
    NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"<span[\\s\\S]*?tid=(\\d*)[^>]+>(.*?)</a>([\\s\\S]*?)uid=(\\d+)\">(.*?)</a>[\\s\\S]*?<em>(.*?)</em>[\\s\\S]*?<strong>(.*?)</strong>/<em>(.*?)</em>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches=[regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tid=[html substringWithRange:[match rangeAtIndex:1]];
        NSString *title=[html substringWithRange:[match rangeAtIndex:2]];
        NSString *hasImageOrHasAttach=[html substringWithRange:[match rangeAtIndex:3]];
        NSString *uid=[html substringWithRange:[match rangeAtIndex:4]];
        NSString *userName=[html substringWithRange:[match rangeAtIndex:5]];
        NSString *dateString=[html substringWithRange:[match rangeAtIndex:6]];
        NSString *replyString=[html substringWithRange:[match rangeAtIndex:7]];
        NSString *openString=[html substringWithRange:[match rangeAtIndex:8]];
//        NSLog(@"tid:%@  title:%@  hasImageOrHasAttach:%@  uid:%@  userName:%@  dateString:%@  replyString:%@  openString:%@",tid,title,hasImageOrHasAttach,uid,userName,dateString,replyString,openString);
        BOOL hasImage=NO;
        BOOL hasAttach=NO;
        if ([hasImageOrHasAttach containsString:@"图片附件"]) {
            hasImage=YES;
        }else if([hasImageOrHasAttach containsString:@"附件"]){
            hasAttach=YES;
        }
        LZUser *user=[[LZUser alloc] initWithAttributes:@{@"uid":[NSNumber numberWithInteger:[uid integerValue]],@"userName":userName}];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[dateFormatter dateFromString:dateString];
        NSInteger replyCount=[replyString integerValue];
        NSInteger openCount=[openString integerValue];
        BOOL hasRead=[[LZPersistenceDataManager sharedPersistenceDataManager] hasReadThreadTid:tid];
        LZThread *thread=[[LZThread alloc]initWithAttributes:@{@"fid":[NSNumber numberWithInteger:fid],@"tid":tid,@"title":title,@"user":user,@"hasRead":[NSNumber numberWithBool:hasRead],@"date":date,@"replyCount":[NSNumber numberWithInteger:replyCount],@"openCount":[NSNumber numberWithInteger:openCount],@"pageCountNumber":[NSNumber numberWithInteger:page],@"hasImage":[NSNumber numberWithBool:hasImage],@"hasAttach":[NSNumber numberWithBool:hasAttach]}];
        [threads addObject:thread];
    }
    return threads;
}

/**
 *  加载帖子详情列表
 *
 *  @param tid     帖子tid
 *  @param page    页数
 *  @param success 成功调用
 *  @param failure 失败调用
 */
-(void)loadPostListTid:(NSString *)tid page:(NSInteger)page isNeedPageFullNumber:(BOOL)isNeed success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    NSString *urlString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/viewthread.php?tid=%@&extra=page%%3D1&page=%ld",tid,page];
    NSDictionary *params=@{@"tid":tid,@"extra":[NSString stringWithFormat:@"page=%ld",page],
                           @"page":[NSString stringWithFormat:@"%ld",page]};
    [self.manager GET:urlString
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSString *html=[NSString ifTheStringIsNilReturnAEmptyString:[NSString encodingGBKStringToIOSString:responseObject]];
                  NSInteger page=1;
                  if (isNeed) {
                      page=[self getPageFullNumber:html];
//                      NSLog(@"%ld",page);
                  }
                  NSArray *threadDetailList=[self getThreadDetailListFromHtml:html];
                  if (threadDetailList==nil) {
                      threadDetailList=[[NSArray alloc]init];
                  }
                  success(@{@"page":[NSNumber numberWithInteger:page],@"threadlist":threadDetailList});
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
}

/**
 *  获得总页数
 *
 *  @param html html字符串
 *
 *  @return 总页数
 */
-(NSInteger)getPageFullNumber:(NSString *)html{
    NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"(\\d+)</a><a\\shref=[^>]*?>下一页</a>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *result=[regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    if ([result count]==0) {
        return 1;
    }
    NSTextCheckingResult *match=(NSTextCheckingResult *)result[0];
    NSString *pageString=[html substringWithRange:[match rangeAtIndex:1] ];
    return [pageString integerValue];
}


/**
 *  返回帖子列表
 *
 *  @param html html字符串
 *
 *  @return 帖子列表字符串
 */
-(NSArray *)getThreadDetailListFromHtml:(NSString *)html{
    html=[html stringByReplacingOccurrencesOfString:@"gbk" withString:@"utf-8"];
    NSData *htmlData=[html dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *htmlParser=[TFHpple hppleWithHTMLData:htmlData];

    NSString *threadListXpathQuertString=@"//div[@id='postlist']/div";
    NSArray *threadList=[htmlParser searchWithXPathQuery:threadListXpathQuertString];
    
    NSMutableArray *threadDetailList=[[NSMutableArray alloc]init];
    for (TFHppleElement *element in threadList) {
        htmlData=[[element raw] dataUsingEncoding:NSUTF8StringEncoding];
        htmlParser=[TFHpple hppleWithHTMLData:htmlData];
        LZThreadDetail *threadDetail=[[LZThreadDetail alloc]init];
        
        //获取发帖时间
        NSRegularExpression *timeRegex=[NSRegularExpression regularExpressionWithPattern:@"<em\\sid=\"authorposton\\d+\">发表于([^<]*)</em>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results=[timeRegex matchesInString:[element raw] options:0 range:NSMakeRange(0, [[element raw] length])];
        threadDetail.time=[[element raw] substringWithRange:[(NSTextCheckingResult *)results[0] rangeAtIndex:1]];
//        NSLog(@"%@",threadDetail.time);
        
        //获取用户信息
        NSString *userXpathQuertString=@"//div[@class='postinfo']/a";
        NSArray *userList=[htmlParser searchWithXPathQuery:userXpathQuertString];
        TFHppleElement *userInfoElement=(TFHppleElement *)userList[0];
        NSString *uidString=[userInfoElement objectForKey:@"href"];
        NSString *userName=[userInfoElement text];
        uidString=[uidString substringFromIndex:[uidString rangeOfString:@"="].location+1];
        LZUser *user=[[LZUser alloc] initWithAttributes:@{@"uid":uidString,@"userName":userName}];
        threadDetail.user=user;
        
        //获取当前楼层
        NSString *postnumXpathQuertString=@"//strong//em";
        NSArray *postnumArray=[htmlParser searchWithXPathQuery:postnumXpathQuertString];
        TFHppleElement *postnumElement=(TFHppleElement *)postnumArray[0];
        threadDetail.postnum=[[postnumElement text] integerValue]-1;
        
        //是否存在回复其他楼层
        NSString *replyXpathQuertString=@"//td[@class='t_msgfont']/strong";
        NSArray *replyArray=[htmlParser searchWithXPathQuery:replyXpathQuertString];
        if ([replyArray count]!=0) {
            TFHppleElement *replyElement=(TFHppleElement *)replyArray[0];
            threadDetail.hasReply=YES;
            NSString *replyString=[replyElement raw];
            NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"<strong>(\\w+)[\\s\\S]*?\"_blank\">([^<]*)<[\\s\\S]*?<i>(\\w+)</i>" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *results=[regex matchesInString:replyString options:0 range:NSMakeRange(0, [replyString length])];
            if ([results count]==0) {
                threadDetail.hasReply=NO;
            }else{
                NSTextCheckingResult *result=(NSTextCheckingResult *)results[0];
                threadDetail.replyString=[NSString stringWithFormat:@"%@ %@ %@",[replyString substringWithRange:[result rangeAtIndex:1]],[replyString substringWithRange:[result rangeAtIndex:2]],[replyString substringWithRange:[result rangeAtIndex:3]]];
            }
        }else{
            threadDetail.hasReply=NO;
        }
        
        
        //是否存在引用其他楼层
        NSString *quoteXpathQuertString=@"//blockquote";
        NSArray *quoteArray=[htmlParser searchWithXPathQuery:quoteXpathQuertString];
        if ([quoteArray count]!=0) {
            TFHppleElement *quoteElement=(TFHppleElement *)quoteArray[0];
            threadDetail.hasQuote=YES;
            NSString *quoteString=[quoteElement raw];
            NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"<blockquote>([^<]*)<[\\s\\S]*?\"#999999\">(\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *results=[regex matchesInString:quoteString options:0 range:NSMakeRange(0, [quoteString length])];
            if ([results count]!=0) {
                NSTextCheckingResult *result=(NSTextCheckingResult *)results[0];
                threadDetail.quoteString=[NSString stringWithFormat:@"%@\n引用 %@",[quoteString substringWithRange:[result rangeAtIndex:1]],[quoteString substringWithRange:[result rangeAtIndex:2]]];
            }
            threadDetail.hasQuote=NO;
        }else{
            threadDetail.hasQuote=NO;
        }
        
        
        //帖子内容原始版
//        NSString *rawContextXpathQuertString=@"//td[@class='t_msgfont']";
//        NSArray *rawContextArray=[htmlParser searchWithXPathQuery:rawContextXpathQuertString];
//        threadDetail.rawContext=[(TFHppleElement *)rawContextArray[0] raw];
        
        NSMutableArray *contextMutableArray=[[NSMutableArray alloc]init];
        //帖子内容
        NSString *contextXpathQuertString=@"//td[@class='t_msgfont']/node()";
        NSArray *contextArray=[htmlParser searchWithXPathQuery:contextXpathQuertString];
        NSMutableString *contextString=[[NSMutableString alloc]init];
        for (TFHppleElement *contextElement in contextArray) {
            //如果既不是回复也不是引用
            if (![[contextElement tagName] isEqualToString:@"strong"]&&![[contextElement objectForKey:@"class"] isEqualToString:@"quote"]&&![[contextElement objectForKey:@"class"]isEqualToString:@"pstatus"]&&![[contextElement tagName]isEqualToString:@"span"]) {
//                if (![[contextElement tagName]isEqualToString:@"img"]) {
//                    NSMutableString *textMutableString=[[NSMutableString alloc] init];
//                    textMutableString=[[contextElement raw] mutableCopy];
//                    [textMutableString replaceOccurrencesOfString:@"&#13;" withString:@"" options:0 range:NSMakeRange(0, [textMutableString length])];
//                    [contextString appendString:textMutableString];
//                }else{
//                    contextString=[[NSString removeDuplicatedEnter:contextString] mutableCopy];
//                    [contextMutableArray addObject:@{THREADLISTDETAILSTRING:contextString}];
//                    contextString=[[NSMutableString alloc]init];
//                    NSString *imageURL;
//                    if ([contextElement objectForKey:@"file"]!=nil) {
//                        imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[contextElement objectForKey:@"file"]];
//                    }else{
//                        imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[contextElement objectForKey:@"src"]];
//                    }
//                    [contextMutableArray addObject:@{THREADLISTDETAILIMAGE:imageURL}];
////                    NSLog(@"%@",imageURL);
//                }
                NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"<img\\ssrc[\\s\\S]*?file=\"([^\"]*)\"" options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray *results=[regex matchesInString:[contextElement raw] options:0 range:NSMakeRange(0, [[contextElement raw]length])];
                
                if ([results count]==0) {
                    NSRegularExpression *srcRegex=[NSRegularExpression regularExpressionWithPattern:@"<img\\ssrc=\"([\\s\\S]*?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSArray *resultsSrc=[srcRegex matchesInString:[contextElement raw] options:0 range:NSMakeRange(0, [[contextElement raw]length])];
                    if ([resultsSrc count]==0) {
                        NSData *htmlDataTemp=[[contextElement raw] dataUsingEncoding:NSUTF8StringEncoding];
                        TFHpple *htmlParserTemp=[TFHpple hppleWithHTMLData:htmlDataTemp];
                        NSString *contextXpathQuertStringTemp=@"/descendant::*/text()";
                        NSArray *allTextResult=[htmlParserTemp searchWithXPathQuery:contextXpathQuertStringTemp];
                        if ([allTextResult count]!=0) {
                            [contextString appendString:[(TFHppleElement *)allTextResult[0] raw]];
                        }
                    }else{
                        contextString=[[NSString removeDuplicatedEnter:contextString] mutableCopy];
                        [contextMutableArray addObject:@{THREADLISTDETAILSTRING:contextString}];
                        contextString=[[NSMutableString alloc]init];
                        for (NSTextCheckingResult *result in resultsSrc) {
                            NSString *imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[[contextElement raw] substringWithRange:[result rangeAtIndex:1]]];
                            [contextMutableArray addObject:@{THREADLISTDETAILIMAGE:imageURL}];
                        }
                    }
                    
                    
                }else{
                    contextString=[[NSString removeDuplicatedEnter:contextString] mutableCopy];
                    [contextMutableArray addObject:@{THREADLISTDETAILSTRING:contextString}];
                    contextString=[[NSMutableString alloc]init];
                    for (NSTextCheckingResult *result in results) {
                        NSString *imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[[contextElement raw] substringWithRange:[result rangeAtIndex:1]]];
                        [contextMutableArray addObject:@{THREADLISTDETAILIMAGE:imageURL}];
                    }
                }
            }
        }
        if ([contextString length]!=0) {
            contextString=[[NSString removeDuplicatedEnter:contextString] mutableCopy];
            [contextMutableArray addObject:@{THREADLISTDETAILSTRING:contextString}];
            contextString=[[NSMutableString alloc]init];
        }
        //附件图片
        NSString *attachFileXpathQuertString=@"//div[@class='postattachlist']//img";
        NSArray *attachFileArray=[htmlParser searchWithXPathQuery:attachFileXpathQuertString];
        if ([attachFileArray count]!=0) {
            for (TFHppleElement *attachImage in attachFileArray) {
                NSString *imageURL;
                if ([attachImage objectForKey:@"file"]!=nil) {
                    imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[attachImage objectForKey:@"file"]];
                }else{
                    imageURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",[attachImage objectForKey:@"src"]];
                }
                [contextMutableArray addObject:@{THREADLISTDETAILIMAGE:imageURL}];
            }
        }
        
        threadDetail.contextArray=contextMutableArray;
        
        [threadDetailList addObject:threadDetail];
    }
    
    
    return threadDetailList;
}

@end
