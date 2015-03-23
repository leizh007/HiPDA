//
//  LZUser.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZUser.h"

@interface LZUser()

@end

@implementation LZUser

/**
 *  设置LZUser
 *
 *  @param attributes uid，userName
 *
 *  @return self
 */
-(id)initWithAttributes:(NSDictionary *)attributes{
    self=[super init];
    if (!self) {
        return nil;
    }
    NSNumber *number=[attributes objectForKey:@"uid"];
    self.uid=[number integerValue];
    self.userName=[attributes objectForKey:@"userName"];
    NSString *avatarImageUrlString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/uc_server/data/avatar/%03ld/%02ld/%02ld/%02ld_avatar_middle.jpg",self.uid/1000000,(self.uid%1000000)/10000,(self.uid%10000)/100,self.uid%100];
    self.avatarImageUrl=[NSURL URLWithString:avatarImageUrlString];
    return self;
    
}

#pragma mark -  NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (!self) {
        return nil;
    }
    self.uid=[aDecoder decodeIntegerForKey:@"uid"];
    self.userName=[aDecoder decodeObjectForKey:@"userName"];
    self.avatarImageUrl=[aDecoder decodeObjectForKey:@"avatarImageUrl"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.avatarImageUrl forKey:@"avatarImageUrl"];
}

@end
