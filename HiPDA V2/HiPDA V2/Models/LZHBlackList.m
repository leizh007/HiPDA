//
//  LZHBlackList.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHBlackList.h"

NSString *const LZHBLACKLIST=@"LZHBLACKLIST";

@interface LZHBlackList()

@property (strong ,nonatomic) NSMutableArray *blackList;

@end

@implementation LZHBlackList

+(id)sharedBlackList{
    static LZHBlackList *blackList=nil;
    static dispatch_once_t onceToke;
    dispatch_once(&onceToke, ^{
        if (blackList==nil) {
            blackList=[[LZHBlackList alloc]init];
        }
    });
    return blackList;
}

-(id)init{
    if (self=[super init]) {
        _blackList=[[[NSUserDefaults standardUserDefaults]objectForKey:LZHBLACKLIST] mutableCopy];
    }
    return self;
}

-(BOOL)isUIDInBlackList:(NSString *)uid{
    if ([_blackList containsObject:uid]) {
        return YES;
    }
    return NO;
}

-(void)addUIDToBlackList:(NSString *)uid{
    [_blackList addObject:uid];
    [self saveBlackList];
}

-(void)removeUIDFromBlackList:(NSString *)uid{
    [_blackList removeObject:uid];
    [self saveBlackList];
}

-(void)saveBlackList{
    [[NSUserDefaults standardUserDefaults]setObject:_blackList forKey:LZHBLACKLIST];
}

@end
