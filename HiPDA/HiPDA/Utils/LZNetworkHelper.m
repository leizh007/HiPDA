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
                                  block(YES,nil);
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

@end
