//
//  LZMainThreadViewController.h
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZMainThreadViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

-(void)getNotifications:(NSNotification *)notification;
-(void)loadForumFid:(NSInteger)fid page:(NSInteger) page forced:(BOOL)isFoced;

@end
