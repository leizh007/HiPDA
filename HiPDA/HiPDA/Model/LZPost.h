//
//  LZPost.h
//  HiPDA
//
//  Created by leizh007 on 15/4/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZUser.h"

@interface LZPost : NSObject

@property (strong, nonatomic) LZUser *user;
@property (strong, nonatomic) NSString *pid;
@property (assign, nonatomic) NSInteger floorNumber;

@end
