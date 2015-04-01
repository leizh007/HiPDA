//
//  LZThreadListTableViewCell.h
//  HiPDA
//
//  Created by leizh007 on 15/4/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZThreadDetail.h"


@interface LZThreadListTableViewCell : UITableViewCell

-(void)configure:(LZThreadDetail *)threadDetail;

@end
