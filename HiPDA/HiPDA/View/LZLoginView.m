//
//  LZLoginView.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZLoginView.h"
#import "FBShimmeringView.h"

#define  DISTANCEBETWEENEACHVIEWLEFT 30
#define  DISTANCEBETWEENEACHVIEWUP   20
#define  INSET                       8

@interface LZLoginView()

@property (strong, nonatomic) UILabel          *hiPdaLabel;
@property (strong, nonatomic) UILabel          *userNameLabel;
@property (strong, nonatomic) UILabel          *userPasswordLabel;
@property (strong, nonatomic) UILabel          *safeQuestionNumberLabel;
@property (strong, nonatomic) UILabel          *safeQuestionAnswerLabel;
@property (strong, nonatomic) FBShimmeringView *shimmerinHipdaView;
@property (strong, nonatomic) FBShimmeringView *shimmerinLoginView;
@end

@implementation LZLoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
        self.hiPdaLabel=[[UILabel alloc]init];
        self.userNameLabel=[[UILabel alloc]init];
        self.userPasswordLabel=[[UILabel alloc]init];
        self.safeQuestionNumberLabel=[[UILabel alloc]init];
        self.safeQuestionAnswerLabel=[[UILabel alloc]init];
        self.userNameTextField=[[UITextField alloc]init];
        self.userPassWoldTextField=[[UITextField alloc]init];
        self.safeQuestionNumberButton=[[UIButton alloc]init];
        self.safeQuestionAnswerTextField=[[UITextField alloc]init];
        self.loginButton=[[UIButton alloc]init];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.userPasswordLabel];
        [self addSubview:self.safeQuestionNumberLabel];
        [self addSubview:self.safeQuestionAnswerLabel];
        [self addSubview:self.userNameTextField];
        [self addSubview:self.userPassWoldTextField];
        [self addSubview:self.safeQuestionNumberButton];
        [self addSubview:self.safeQuestionAnswerTextField];
        //[self addSubview:self.loginButton];
        self.userNameLabel.text=@"用户名";
        self.userPasswordLabel.text=@"密码";
        self.safeQuestionNumberLabel.text=@"安全提问";
        self.safeQuestionAnswerLabel.text=@"答案";
        [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
        NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc] initWithString:@"Hi!PDA论坛登录"];
        NSDictionary *attr=@{NSFontAttributeName:[UIFont boldSystemFontOfSize:25],NSForegroundColorAttributeName:[UIColor colorWithRed:0.568 green:0.525 blue:0.678 alpha:1]};
        [attributedString setAttributes:attr range:NSMakeRange(0, attributedString.length)];
        self.hiPdaLabel.attributedText=attributedString;
        [self.hiPdaLabel sizeToFit];
        self.shimmerinHipdaView=[[FBShimmeringView alloc]init];
        [self addSubview:self.shimmerinHipdaView];
        self.shimmerinHipdaView.contentView=self.hiPdaLabel;
        self.shimmerinHipdaView.shimmering=YES;
        UITapGestureRecognizer *gestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
        [gestureRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:gestureRecognizer];
        self.userPassWoldTextField.delegate=self;
        self.userNameTextField.delegate=self;
        self.safeQuestionAnswerTextField.delegate=self;
        self.shimmerinLoginView=[[FBShimmeringView alloc]init];
        [self addSubview:self.shimmerinLoginView];
        self.shimmerinLoginView.contentView=self.loginButton;
        self.shimmerinLoginView.shimmering=YES;
        self.safeQuestionNumberButton.tag=SAFEQUESTIONBUTTONTAG;
        self.loginButton.tag=LOGINBUTTONTAG;
    }
    return self;
}

-(void)layoutSubviews{
    //设置标题label
    self.shimmerinHipdaView.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width/2-self.hiPdaLabel.frame.size.width/2, 35, self.hiPdaLabel.frame.size.width, self.hiPdaLabel.frame.size.height);
    
    //设置第一层
    [self.userNameLabel sizeToFit];
    self.userNameLabel.frame=CGRectMake(DISTANCEBETWEENEACHVIEWLEFT, self.shimmerinHipdaView.frame.origin.y+self.shimmerinHipdaView.frame.size.height+1.5*DISTANCEBETWEENEACHVIEWUP, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height);
    self.userNameTextField.frame=CGRectMake(self.userNameLabel.frame.origin.x+self.userNameLabel.frame.size.width+DISTANCEBETWEENEACHVIEWLEFT/2, self.userNameLabel.frame.origin.y-INSET/2, [[UIScreen mainScreen] bounds].size.width-self.userNameLabel.frame.size.width-4*DISTANCEBETWEENEACHVIEWUP, self.userNameLabel.frame.size.height+INSET);
    [self setTextField:self.userNameTextField];
    self.userNameTextField.placeholder=@"请输入用户名";
    
    int leftLabelRighPosition=self.userNameLabel.frame.origin.x+self.userNameLabel.frame.size.width;
    
    //设置第二层
    [self.userPasswordLabel sizeToFit];
    self.userPasswordLabel.frame=CGRectMake(leftLabelRighPosition-self.userPasswordLabel.frame.size.width, self.userNameLabel.frame.origin.y+self.userNameLabel.frame.size.height+DISTANCEBETWEENEACHVIEWUP, self.userPasswordLabel.frame.size.width, self.userPasswordLabel.frame.size.height);
    self.userPassWoldTextField.frame=CGRectMake(self.userNameTextField.frame.origin.x, self.userPasswordLabel.frame.origin.y-INSET/2, self.userNameTextField.frame.size.width, self.userNameTextField.frame.size.height);
    [self setTextField:self.userPassWoldTextField];
    self.userPassWoldTextField.placeholder=@"请输入密码";
    self.userPassWoldTextField.secureTextEntry=YES;
    
    //设置第三层
    [self.safeQuestionNumberLabel sizeToFit];
    self.safeQuestionNumberLabel.frame=CGRectMake(leftLabelRighPosition-self.safeQuestionNumberLabel.frame.size.width, self.userPasswordLabel.frame.origin.y+self.userPasswordLabel.frame.size.height+DISTANCEBETWEENEACHVIEWUP, self.safeQuestionNumberLabel.frame.size.width, self.safeQuestionNumberLabel.frame.size.height);
    self.safeQuestionNumberButton.frame=CGRectMake(self.userPassWoldTextField.frame.origin.x, self.safeQuestionNumberLabel.frame.origin.y-INSET/2, self.userPassWoldTextField.frame.size.width, self.userPassWoldTextField.frame.size.height);
    //self.safeQuestionNumberButton.backgroundColor=[UIColor greenColor];
    self.safeQuestionNumberButton.layer.borderWidth=1.0;
    self.safeQuestionNumberButton.layer.borderColor=[[UIColor colorWithRed:0.568 green:0.525 blue:0.678 alpha:1] CGColor];
    self.safeQuestionNumberButton.layer.cornerRadius=5.0;
    [self.safeQuestionNumberButton setTitle:@"安全提问" forState:UIControlStateNormal];
    self.safeQuestionNumberButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    self.safeQuestionNumberButton.layer.sublayerTransform=CATransform3DMakeTranslation(5, 0, 0);
    [self.safeQuestionNumberButton setTitleColor:[UIColor colorWithRed:0.66 green:0.782 blue:0.681 alpha:1] forState:UIControlStateNormal];
    
    //设置第四层
    [self.safeQuestionAnswerLabel sizeToFit];
    self.safeQuestionAnswerLabel.frame=CGRectMake(leftLabelRighPosition-self.safeQuestionAnswerLabel.frame.size.width, self.safeQuestionNumberLabel.frame.origin.y+self.safeQuestionNumberLabel.frame.size.height+DISTANCEBETWEENEACHVIEWUP, self.safeQuestionAnswerLabel.frame.size.width, self.safeQuestionAnswerLabel.frame.size.height);
    self.safeQuestionAnswerTextField.frame=CGRectMake(self.safeQuestionNumberButton.frame.origin.x, self.safeQuestionAnswerLabel.frame.origin.y-INSET/2, self.safeQuestionNumberButton.frame.size.width, self.safeQuestionNumberButton.frame.size.height);
    [self setTextField:self.safeQuestionAnswerTextField];
    self.safeQuestionAnswerTextField.placeholder=@"空";
    
    //设置第五层
    self.shimmerinLoginView.frame=CGRectMake(DISTANCEBETWEENEACHVIEWLEFT, self.safeQuestionAnswerTextField.frame.origin.y+self.safeQuestionAnswerTextField.frame.size.height+2*DISTANCEBETWEENEACHVIEWUP, [[UIScreen mainScreen]bounds].size.width-2*DISTANCEBETWEENEACHVIEWLEFT, self.safeQuestionAnswerTextField.frame.size.height+INSET);
    self.loginButton.backgroundColor=[UIColor colorWithRed:0.181 green:0.331 blue:0.792 alpha:1];
    self.loginButton.layer.cornerRadius=5.0;
    self.loginButton.layer.borderWidth=1.0;
    self.loginButton.layer.borderColor=[[UIColor colorWithRed:0.568 green:0.525 blue:0.678 alpha:1] CGColor];
}

/**
 *  收起键盘
 *
 *  @param sender
 */
-(void)dismissKeyboard:(id)sender{
    [self.userNameTextField endEditing:YES];
    [self.userPassWoldTextField endEditing:YES];
    [self.safeQuestionAnswerTextField endEditing:YES];
}

/**
 *  输入return收起键盘
 *
 *  @param textField
 *
 *  @return
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

/**
 *  设置textfield的外观
 *
 *  @param sender 要设置的textfield
 */
-(void)setTextField:(id)sender{
    UITextField *textField=(UITextField *)sender;
    textField.layer.borderColor=[[UIColor colorWithRed:0.568 green:0.525 blue:0.678 alpha:1] CGColor];
    textField.layer.borderWidth=1.0;
    textField.layer.cornerRadius=5.0;
    textField.layer.sublayerTransform=CATransform3DMakeTranslation(5, 0, 0);//输入内容右移5个像素
}

@end
