//
//  LZHSendPmViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSendPmViewController.h"
#import "UIImage+LZHHIPDA.h"
#import "MZFormSheetController.h"
#import "LZHShowMessage.h"

#define LZHSendPmButtonBackgroundColor [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define LZHSendPmButtonHighlightedBackgroundColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2]
#define LZHSendPmButtonHighlightedTitleColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

@interface LZHSendPmViewController ()<UITextViewDelegate>

@end

@implementation LZHSendPmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth=300;
    
    self.view.backgroundColor=[UIColor clearColor];
    
    _textView=[[UITextView alloc]initWithFrame:CGRectMake(0, 8, screenWidth, 140.0f)];
    _textView.editable=YES;
    _textView.backgroundColor=[UIColor whiteColor];
    _textView.layer.cornerRadius=7.0f;
    [_textView setFont:[UIFont systemFontOfSize:17]];
    _textView.text=_message;
    _textView.delegate=self;
    
    _cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(screenWidth/8, _textView.frame.size.height+_textView.frame.origin.y+8.0f, screenWidth/4, 30)];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self setPropertiesOfButton:_cancelButton];
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _sendButton=[[UIButton alloc]initWithFrame:CGRectMake(5*screenWidth/8, _cancelButton.frame.origin.y, screenWidth/4, 30)];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self setPropertiesOfButton:_sendButton];
    [_sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_textView];
    [self.view addSubview:_cancelButton];
    [self.view addSubview:_sendButton];
    
    [self textView:_textView shouldChangeTextInRange:NSMakeRange(0, 1) replacementText:_textView.text];
}


-(void)setPropertiesOfButton:(UIButton *)button{
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:LZHSendPmButtonHighlightedTitleColor forState:UIControlStateDisabled];
    [button setTitleColor:LZHSendPmButtonHighlightedTitleColor forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithColor:LZHSendPmButtonBackgroundColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:LZHSendPmButtonHighlightedBackgroundColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithColor:LZHSendPmButtonHighlightedBackgroundColor] forState:UIControlStateDisabled];
    button.layer.cornerRadius=7.0f;
    button.clipsToBounds=YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.formSheetController setNeedsStatusBarAppearanceUpdate];
    }];
    
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Button Pressed

-(void)cancelButtonPressed:(id)sender{
    [_delegate didFinishEdittingMessage:_textView.text isSend:NO];
    [self.navigationController.formSheetController mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

-(void)sendButtonPressed:(id)sender{
    [_delegate didFinishEdittingMessage:_textView.text isSend:YES];
    [self.navigationController.formSheetController mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - TextView Delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length > 1 || (text.length > 0 && ![text isEqualToString:@""]))
    {
        _sendButton.enabled = YES;
    }
    else
    {
        _sendButton.enabled = NO;
    }
    
    return YES;
}

@end
