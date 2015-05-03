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
        if (_blackList==nil) {
            _blackList=[[NSMutableArray alloc]init];
        }
    }
    return self;
}

-(BOOL)isUserNameInBlackList:(NSString *)userName{
    if ([_blackList containsObject:userName]) {
        return YES;
    }
    return NO;
}

-(void)addUserNameToBlackList:(NSString *)userName{
    if (![self isUserNameInBlackList:userName]) {
        [_blackList addObject:userName];
        [self saveBlackList];
    }
}

-(void)removeUserNameFromBlackList:(NSString *)userName{
    [_blackList removeObject:userName];
    [self saveBlackList];
}

-(void)saveBlackList{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:_blackList forKey:LZHBLACKLIST];
    [defaults synchronize];
}

@end
