//
//  LZViewThreadDetailViewController.h
//  HiPDA
//
//  Created by leizh007 on 15/3/30.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "LZUser.h"

@interface LZViewThreadDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RTLabelDelegate>

@property (strong, nonatomic) NSString *tid;
@property (strong, nonatomic) NSString *threadTitle;
@property (assign, nonatomic) NSInteger fid;
@property (strong, nonatomic) LZUser *user;

@end
