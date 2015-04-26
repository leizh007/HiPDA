//
//  LZHUser.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LZHUSERUSERNAME;
extern NSString *const LZHUSERUID;

@interface LZHUser : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSURL *avatarImageURL;

-(id)initWithAttributes:(NSDictionary *)attributes;

@end
