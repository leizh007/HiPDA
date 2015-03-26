//
//  LZCache.m
//  HiPDA
//
//  Created by leizh007 on 15/3/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZCache.h"

@interface LZCache()


@end

@implementation LZCache

+(id)globalCache{
    static LZCache *cache=nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        cache=[[LZCache alloc]init];
    });
    return cache;
}

/**
 *  缓存帖子列表一天
 *
 *  @param threads 帖子列表
 *  @param fid     版块号
 *  @param page    页数
 */
-(void)cacheForum:(NSArray *)threads fid:(NSInteger)fid page:(NSInteger)page{
    NSString *keyForCacheForForum=[NSString stringWithFormat:@"fid=%ld&page=%ld",(long)fid,(long)page];
    [[EGOCache globalCache] setObject:threads forKey:keyForCacheForForum withTimeoutInterval:86400.0f];
}

/**
 *  获取缓存的帖子列表
 *
 *  @param fid  版块号
 *  @param page 页数
 *
 *  @return 帖子列表
 */
-(NSArray *)loadForumCacheFid:(NSInteger)fid page:(NSInteger)page{
    NSString *keyForCacheForForum=[NSString stringWithFormat:@"fid=%ld&page=%ld",(long)fid,(long)page];
    return (NSArray *)[[EGOCache globalCache] objectForKey:keyForCacheForForum];
}

@end
