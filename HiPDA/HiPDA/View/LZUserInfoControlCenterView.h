//
//  LZUserInfoControlCenterView.h
//  HiPDA
//
//  Created by leizh007 on 15/3/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MYBUTTONTAG 1
#define MSGBUTTONTAG 2
#define SETTINGBUTTONTAG 3

@interface LZUserInfoControlCenterView : UIView

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UIButton *myButton;
@property (strong, nonatomic) UIButton *msgButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UITableView *tableView;

@end
