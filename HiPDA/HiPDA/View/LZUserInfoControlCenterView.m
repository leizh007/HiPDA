//
//  LZUserInfoControlCenterView.m
//  HiPDA
//
//  Created by leizh007 on 15/3/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZUserInfoControlCenterView.h"

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
        self.backgroundColor=[UIColor whiteColor];
        
        self.avatarImageView=[[UIImageView alloc]init];
        self.userNameLabel=[[UILabel alloc]init];
        self.userNameLabel.textColor=[UIColor blackColor];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.userNameLabel];
    }
    return self;
}

-(void)layoutSubviews{
    self.avatarImageView.frame=CGRectMake(0, 0, 40, 40);
    self.userNameLabel.frame=CGRectMake(0, 50, 40, 40);
}

@end
