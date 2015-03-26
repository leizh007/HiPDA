//
//  LZThreadTableViewCell.h
//  HiPDA
//
//  Created by leizh007 on 15/3/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZThread.h"
#import "LZUser.h"

@interface LZThreadTableViewCell : UITableViewCell

-(void)configure:(LZThread *)thread;
+(CGFloat)getCellHeight:(LZThread *)thread;

@end
