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

+(id)sharedPersistenceDataManager{
    static LZPersistenceDataManager *persistenceDataManager=nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        persistenceDataManager=[[LZPersistenceDataManager alloc]init];
    });
    return persistenceDataManager;
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
        return NO;
    }
    return YES;
}


/**
 *  把一个帖子加入已读列表
 *
 *  @param tid 帖子tid
 */
-(void)addThreadTidToHasRead:(NSString *)tid{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *now = [NSDate date];
    NSString *dateString = [format stringFromDate:now];
    [self.hasReadDic setObject:dateString forKey:tid];
    if ([self.hasReadDic count]>=2000) {
        [self deleteSomeUnnecessaryValues];
    }
    [self storeHasReadThreads];
}

/**
 *  保存已读列表
 */
-(void)storeHasReadThreads{
    [[NSUserDefaults standardUserDefaults] setObject:self.hasReadDic forKey:@"hasReadDic"];
}

/**
 *  已读帖子列表过多了之后删除掉一些
 */
-(void)deleteSomeUnnecessaryValues{
    NSMutableArray *values=[[self.hasReadDic allValues] mutableCopy];
    [values sortedArrayUsingSelector:@selector(compare:)];
    NSMutableDictionary *muDic=[[NSMutableDictionary alloc]initWithDictionary:self.hasReadDic];
    for (NSString *key in [self.hasReadDic allKeys]) {
        if ([[self.hasReadDic objectForKey:key] compare:values[[values count]/2]]==NSOrderedAscending) {
            [muDic removeObjectForKey:key];
        }
    }
    self.hasReadDic=muDic;
}
@end
