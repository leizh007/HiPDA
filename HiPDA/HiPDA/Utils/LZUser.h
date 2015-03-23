//
//  LZUser.h
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZUser : NSObject<NSCoding>

@property (assign, nonatomic) NSInteger uid;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSURL *avatarImageUrl;

-(id)initWithAttributes:(NSDictionary *)attributes;

@end
