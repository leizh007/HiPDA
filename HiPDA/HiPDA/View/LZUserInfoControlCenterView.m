//
//  LZUserInfoControlCenterView.m
//  HiPDA
//
//  Created by leizh007 on 15/3/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZUserInfoControlCenterView.h"

#define DEFAULTBACKGROUNDCOLOR ([UIColor colorWithRed:0.134 green:0.162 blue:0.188 alpha:1])
#define HIGHLIGHTEDBACKGROUNDCOLOR ([UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1])
#define DEFAULTFONOTCOLOR ([UIColor colorWithRed:0.581 green:0.6 blue:0.617 alpha:1])
#define HIGHLIGHEDFONTCOLOR ([UIColor colorWithRed:0.999 green:1 blue:1 alpha:1])
#define SEPERATORLINECOLOR ([UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1])
#define INSETBETWEENVIEWELEMENTS 8
#define BUTTONWIDTHANDHEIGHT 40

@interface LZUserInfoControlCenterView()



@end

@implementation LZUserInfoControlCenterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=DEFAULTBACKGROUNDCOLOR;
        
        self.avatarImageView=[[UIImageView alloc]init];
        self.userNameLabel=[[UILabel alloc]init];
        self.userNameLabel.textColor=DEFAULTFONOTCOLOR;
        self.myButton=[[UIButton alloc]init];
        self.myButton.tag=MYBUTTONTAG;
        self.msgButton=[[UIButton alloc]init];
        self.msgButton.tag=MSGBUTTONTAG;
        self.settingButton=[[UIButton alloc]init];
        self.settingButton.tag=SETTINGBUTTONTAG;
        self.tableView=[[UITableView alloc]init];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.myButton];
        [self addSubview:self.msgButton];
        [self addSubview:self.settingButton];
        [self addSubview:self.tableView];
    }
    return self;
}

-(void)layoutSubviews{
    self.avatarImageView.frame=CGRectMake(20, 40, 45, 45);
    self.avatarImageView.layer.cornerRadius=15.0;
    [self.avatarImageView.layer setMasksToBounds:YES];
    self.avatarImageView.layer.borderColor=[[UIColor blackColor] CGColor];
    self.avatarImageView.layer.borderWidth=1.0;
    [self.userNameLabel sizeToFit];
    self.userNameLabel.frame=CGRectMake(self.avatarImageView.frame.origin.x+self.avatarImageView.frame.size.width+INSETBETWEENVIEWELEMENTS, self.avatarImageView.frame.origin.y+self.avatarImageView.frame.size.height/2-self.userNameLabel.frame.size.height/2, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height);
    self.myButton.frame=CGRectMake(self.avatarImageView.frame.origin.x, self.avatarImageView.frame.origin.y+self.avatarImageView.frame.size.height+INSETBETWEENVIEWELEMENTS, BUTTONWIDTHANDHEIGHT, 1.5*BUTTONWIDTHANDHEIGHT);
    [self.myButton setTitle:@"我的" forState:UIControlStateNormal];
    [self.myButton setTitleColor:DEFAULTFONOTCOLOR forState:UIControlStateNormal];
    self.myButton.backgroundColor=[UIColor clearColor];
    
    self.msgButton.frame=CGRectMake(self.myButton.frame.origin.x+BUTTONWIDTHANDHEIGHT+INSETBETWEENVIEWELEMENTS, self.myButton.frame.origin.y, BUTTONWIDTHANDHEIGHT, 1.5*BUTTONWIDTHANDHEIGHT);
    [self.msgButton setTitle:@"消息" forState:UIControlStateNormal];
    [self.msgButton setTitleColor:DEFAULTFONOTCOLOR forState:UIControlStateNormal];
    
    self.settingButton.frame=CGRectMake(self.msgButton.frame.origin.x+BUTTONWIDTHANDHEIGHT+INSETBETWEENVIEWELEMENTS, self.msgButton.frame.origin.y, BUTTONWIDTHANDHEIGHT, 1.5*BUTTONWIDTHANDHEIGHT);
    [self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingButton setTitleColor:DEFAULTFONOTCOLOR forState:UIControlStateNormal];
    
    self.tableView.frame=CGRectMake(0, self.myButton.frame.origin.y+1.5*BUTTONWIDTHANDHEIGHT+INSETBETWEENVIEWELEMENTS, REARVIEWREVEALWIDTH, [[UIScreen mainScreen]bounds].size.height-self.myButton.frame.origin.y-BUTTONWIDTHANDHEIGHT-INSETBETWEENVIEWELEMENTS);
}


@end
