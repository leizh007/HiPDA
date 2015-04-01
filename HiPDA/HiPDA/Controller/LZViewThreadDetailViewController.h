//
//  LZViewThreadDetailViewController.h
//  HiPDA
//
//  Created by leizh007 on 15/3/30.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZViewThreadDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSString *tid;
@property (strong, nonatomic) NSString *threadTitle;

@end
