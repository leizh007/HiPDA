//
//  LZHThreadViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

extern NSString *const LZHThreadDataSourceChange;
extern NSString *const LZHDiscoveryFidString;
extern NSString *const LZHBuyAndSellFidString;
extern NSString *const LZHGeekTalkFidString;
extern NSString *const LZHMachineFidString;
extern NSString *const LZHEINKFidString;

@interface LZHThreadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>

-(void)handleNotification:(NSNotification *)notification;

@end
