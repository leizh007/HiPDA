//
//  LZHPostViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPostViewController.h"
#import "MTLog.h"

@interface LZHPostViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation LZHPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _webView=[[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.delegate=self;
}


#pragma mark - UIWebView Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
