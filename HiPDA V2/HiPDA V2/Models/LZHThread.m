//
//  LZThread.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHThread.h"
#import "LZHUser.h"
#import "NSString+LZHHIPDA.h"
#import "LZHBlackList.h"
#import "LZHReadList.h"
#import "LZHHTTPRequestOperationManager.h"
#import "LZHHtmlParser.h"

@interface LZHThread()

@end

@implementation LZHThread

-(id)initWithUser:(LZHUser *)user replyCount:(NSInteger)replyCount totalCount:(NSInteger)totalCount postTime:(NSString *)postTime title:(NSString *)title tid:(NSString *)tid hasAttach:(BOOL)hasAttach hasImage:(BOOL)hasImage hasRead:(BOOL)hasRead isUserInBlackList:(BOOL)isUserInBlackList{
    if (self=[super init]) {
        _user=user;
        _replyCount=replyCount;
        _totalCount=totalCount;
        _postTime=[NSString timeAgo:postTime];
        _hasAttach=hasAttach;
        _hasImage=hasImage;
        _tid=tid;
        _hasRead=[[LZHReadList sharedReadList]hasReadTid:tid];
        _isUserInBlackList=[[LZHBlackList sharedBlackList] isUserNameInBlackList:user.userName];
        _title=title;
        if (hasImage) {
            _title=[NSString stringWithFormat:@"%@🎑",title];
        }else if(hasAttach){
            _title=[NSString stringWithFormat:@"%@📎",title];
        }
        _hasRead=hasRead;
        _isUserInBlackList=isUserInBlackList;
    }
    return self;
}

+(void)loadForumFid:(NSInteger)fid page:(NSInteger)page completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    NSString *requestURL=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/forumdisplay.php?fid=%ld&page=%ld",fid,page];
    NSDictionary *requestParameters=@{@"fid":[NSNumber numberWithInteger:fid],
                                      @"page":[NSNumber numberWithInteger:page]};
    [manager GET:requestURL
      parameters:requestParameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responHtmlString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractThreadsFromHtmlString:responHtmlString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             completion(nil,error);
         }];
}
@end
