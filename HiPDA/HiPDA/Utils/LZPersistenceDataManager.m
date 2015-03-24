//
//  LZPersistenceDataManager.m
//  HiPDA
//
//  Created by leizh007 on 15/3/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZPersistenceDataManager.h"

@interface LZPersistenceDataManager()

@property (strong, nonatomic) NSMutableDictionary *hasReadDic;

@end

@implementation LZPersistenceDataManager

-(id)sharedPersistenceDataManager{
    static LZPersistenceDataManager *persistenceDataManager=nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        persistenceDataManager=[[LZPersistenceDataManager alloc]init];
    });
    return self;
}

-(id)init{
    self=[super self];
    if (!self) {
        return nil;
    }
    self.hasReadDic=[[[NSUserDefaults standardUserDefaults]objectForKey:@"hasReadDic"] mutableCopy];
    if (self.hasReadDic==nil) {
        self.hasReadDic=[[NSMutableDictionary alloc]init];
    }
    return self;
}

/**
 *  判断一个帖子是否是已读的
 *
 *  @param tid 帖子的tid
 *
 *  @return 已读返回YES，否则返回NO
 */
-(BOOL)hasReadThreadTid:(NSString *)tid{
    if ([self.hasReadDic objectForKey:tid]==nil) {
        return YES;
    }
    return NO;
}


/**
 *  把一个帖子加入已读列表
 *
 *  @param tid 帖子tid
 */
-(void)addThreadTidToHasRead:(NSString *)tid{
    [self.hasReadDic setObject:@"hasRead" forKey:tid];
}

@end
