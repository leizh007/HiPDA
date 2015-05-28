//
//  LZHMyThreadsTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHMyThreads;

@interface LZHMyThreadsTableViewCell : UITableViewCell

-(void)configureMyThreads:(LZHMyThreads *)myThread;
+(CGFloat)cellHeightForMyThreads:(LZHMyThreads *)myThread;

@end
