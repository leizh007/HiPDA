//
//  LZHMyThreadsTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHMyThread;

@interface LZHMyThreadsTableViewCell : UITableViewCell

-(void)configureMyThreads:(LZHMyThread *)myThread;
+(CGFloat)cellHeightForMyThreads:(LZHMyThread *)myThread;

@end
