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
        _isUserInBlackList=[[LZHBlackList sharedBlackList] isUIDInBlackList:user.uid];
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

@end
