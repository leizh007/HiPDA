//
//  LZHReadList.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHReadList.h"

NSString *const LZHREADLIST=@"LZHREADLIST";

@interface LZHReadList()

@property (strong, nonatomic) NSCache *readListCache;

@end

@implementation LZHReadList

+(id)sharedReadList{
    static LZHReadList *readList=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(readList==nil){
            readList=[[LZHReadList alloc]init];
        }
    });
    return  readList;
}

-(id)init{
    if (self=[super init]) {
        _readListCache=[[NSCache alloc]init];
    }
    return self;
}

-(BOOL)hasReadTid:(NSString *)tid{
    if ([_readListCache objectForKey:tid]!=nil) {
        return YES;
    }
    return NO;
}

-(void)addTid:(NSString *)tid{
    [_readListCache setObject:LZHREADLIST forKey:tid];
}

@end
