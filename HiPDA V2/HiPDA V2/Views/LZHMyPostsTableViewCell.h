//
//  LZHMyPostsTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHMyPosts;

@interface LZHMyPostsTableViewCell : UITableViewCell

-(void)configureMyPosts:(LZHMyPosts *)myPosts;
+(CGFloat)cellHeightForMyPosts:(LZHMyPosts *)myPosts;

@end
