//
//  LZHUser.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHUser.h"

NSString *const LZHUSERUSERNAME=@"LZHUSERUSERNAME";
NSString *const LZHUSERUID=@"LZHUSERUID";

@interface LZHUser()

@end

@implementation LZHUser

-(id)initWithAttributes:(NSDictionary *)attributes{
    self=[super init];
    if (!self) {
        return nil;
    }
    _uid=[attributes objectForKey:LZHUSERUID];
    _userName=[attributes objectForKey:LZHUSERUSERNAME];
    NSInteger uidInteger=[_uid integerValue];
    NSString *avatarImageUrlString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg",uidInteger/1000000,(uidInteger%1000000)/10000,(uidInteger%10000)/100,uidInteger%100];
    _avatarImageURL=[NSURL URLWithString:avatarImageUrlString];
    return self;
}

@end
