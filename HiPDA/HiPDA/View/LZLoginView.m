//
//  LZLoginView.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZLoginView.h"
#import "FBShimmeringView.h"

#define  DISTANCEBETWEENEACHVIEW 20
#define  INSET                   6

@interface LZLoginView()

@property (strong, nonatomic) UILabel          *hiPdaLabel;
@property (strong, nonatomic) UILabel          *userNameLabel;
@property (strong, nonatomic) UILabel          *userPasswordLabel;
@property (strong, nonatomic) UILabel          *safeQuestionNumberLabel;
@property (strong, nonatomic) UILabel          *safeQuestionAnswerLabel;
@property (strong, nonatomic) FBShimmeringView *shimmerinHipdaView;

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
        self.backgroundColor=[UIColor whiteColor];
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
        [self addSubview:self.loginButton];
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
    }
    return self;
}

-(void)layoutSubviews{
    self.shimmerinHipdaView.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width/2-self.hiPdaLabel.frame.size.width/2, 35, self.hiPdaLabel.frame.size.width, self.hiPdaLabel.frame.size.height);
    [self.userNameLabel sizeToFit];
    self.userNameLabel.frame=CGRectMake(DISTANCEBETWEENEACHVIEW, self.shimmerinHipdaView.frame.origin.y+self.shimmerinHipdaView.frame.size.height+2*DISTANCEBETWEENEACHVIEW, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height);
    self.userNameTextField.frame=CGRectMake(self.userNameLabel.frame.origin.x+self.userNameLabel.frame.size.width+DISTANCEBETWEENEACHVIEW, self.userNameLabel.frame.origin.y-INSET/2, [[UIScreen mainScreen] bounds].size.width-self.userNameLabel.frame.size.width-5*DISTANCEBETWEENEACHVIEW, self.userNameLabel.frame.size.height+INSET);
    [self setTextField:self.userNameTextField];
    self.userNameTextField.placeholder=@"请输入用户名";
    [self.userPasswordLabel sizeToFit];
    self.userPasswordLabel.frame=CGRectMake(DISTANCEBETWEENEACHVIEW, self.userNameLabel.frame.origin.y+self.userNameLabel.frame.size.height+2*DISTANCEBETWEENEACHVIEW, self.userPasswordLabel.frame.size.width, self.userPasswordLabel.frame.size.height);
    self.userPassWoldTextField.frame=CGRectMake(self.userNameTextField.frame.origin.x, self.userPasswordLabel.frame.origin.y-INSET/2, self.userNameTextField.frame.size.width, self.userNameTextField.frame.size.height);
    [self setTextField:self.userPassWoldTextField];
    self.userPassWoldTextField.placeholder=@"请输入密码";
}

-(void)dismissKeyboard:(id)sender{
    [self.userNameTextField endEditing:YES];
    [self.userPassWoldTextField endEditing:YES];
    [self.safeQuestionAnswerTextField endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)setTextField:(id)sender{
    UITextField *textField=(UITextField *)sender;
    textField.layer.borderColor=[[UIColor colorWithRed:0.568 green:0.525 blue:0.678 alpha:1] CGColor];
    textField.layer.borderWidth=1.0;
    textField.layer.cornerRadius=5.0;
    textField.layer.sublayerTransform=CATransform3DMakeTranslation(5, 0, 0);//输入内容右移5个像素
}

@end
