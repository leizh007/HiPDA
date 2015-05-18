//
//  LZHMessagesViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/17.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class LZHUser;

@interface LZHMessagesViewController : JSQMessagesViewController

@property (strong, nonatomic) LZHUser *friend;
/**
 *  3:最近三天  4:本周  5:全部
 */
@property (assign, nonatomic) NSInteger dateRange;

@property (strong, nonatomic) UIImage *myAvatar;
@property (strong, nonatomic) UIImage *friendAvatar;

@end
