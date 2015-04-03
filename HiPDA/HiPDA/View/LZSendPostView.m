//
//  LZSendPostView.m
//  HiPDA
//
//  Created by leizh007 on 15/4/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZSendPostView.h"

@interface LZSendPostView()

@property (strong, nonatomic) UILabel *upDownLabel;
@property (strong, nonatomic) UILabel *leftRigthLabel;

@end

@implementation LZSendPostView

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
        self.classificationButton=[[UIButton alloc]init];
        self.titleTextField=[[UITextField alloc]init];
        [self addSubview:self.classificationButton];
        [self addSubview:self.titleTextField];
        self.contentTextView=[[UITextView alloc]init];
        [self addSubview:self.contentTextView];
        self.upDownLabel=[[UILabel alloc]init];
        [self addSubview:self.upDownLabel];
        self.leftRigthLabel=[[UILabel alloc]init];
        [self addSubview:self.leftRigthLabel];
    }
    self.backgroundColor=[UIColor whiteColor];
    return self;
}

-(void)layoutSubviews{
    if (self.postType==POSTTYPENEWTHREAD) {
        self.classificationButton.frame=CGRectMake(0, 64, 100, 30);
        [self.classificationButton setTitle:@"分类" forState:UIControlStateNormal];
        [self.classificationButton setTitleColor:[UIColor colorWithRed:0.239 green:0.683 blue:0.988 alpha:1] forState:UIControlStateNormal];
        [self.classificationButton setTitleColor:[UIColor colorWithRed:0.775 green:0.77 blue:1 alpha:0.1] forState:UIControlStateHighlighted];
        self.classificationButton.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:16];
        self.titleTextField.frame=CGRectMake( self.classificationButton.frame.origin.x+1+self.classificationButton.frame.size.width,self.classificationButton.frame.origin.y, self.frame.size.width-self.classificationButton.frame.size.width, self.classificationButton.frame.size.height);
        self.titleTextField.textColor=[UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1];
        self.titleTextField.placeholder=@"请输入主题";
        self.titleTextField.layer.sublayerTransform=CATransform3DMakeTranslation(5, 0, 0);//输入内容右移5个像素
        self.contentTextView.frame=CGRectMake(self.classificationButton.frame.origin.x, self.classificationButton.frame.origin.y+self.classificationButton.frame.size.height+1, self.frame.size.width,self.frame.size.height-self.classificationButton.frame.size.height -self.classificationButton.frame.origin.y);
        self.titleTextField.font=[UIFont fontWithName:@"HelveticaNeue" size:16];
        self.upDownLabel.frame=CGRectMake(self.classificationButton.frame.size.width+self.classificationButton.frame.origin.x, self.classificationButton.frame.origin.y, 1, self.classificationButton.frame.size.height);
        self.upDownLabel.backgroundColor=[UIColor grayColor];
        self.leftRigthLabel.frame=CGRectMake(self.classificationButton.frame.origin.x, self.classificationButton.frame.origin.y+self.classificationButton.frame.size.height, self.frame.size.width, 1);
        self.leftRigthLabel.backgroundColor=[UIColor grayColor];
    }else{
        self.contentTextView.frame=CGRectMake(0, 64, self.frame.size.width,self.frame.size.height);
    }
    self.contentTextView.scrollEnabled=NO;
    self.contentTextView.textColor=[UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1];
    self.contentTextView.font=[UIFont fontWithName:@"HelveticaNeue" size:16];
//    self.contentTextView.pl
}


@end
