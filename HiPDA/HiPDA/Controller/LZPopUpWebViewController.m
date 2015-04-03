//
//  LZPopUpWebViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/4/2.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZPopUpWebViewController.h"
#import "UIBarButtonItem+ImageItem.h"

@interface LZPopUpWebViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation LZPopUpWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor greenColor];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem=[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=buttonItem;
    
    self.webView=[[UIWebView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];
    
    UIBarButtonItem *refreshButton=[UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"refreshButton"] target:self action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem=refreshButton;
}

-(void)viewDidAppear:(BOOL)animated{
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)refresh:(id)sender{
    [self.webView reload];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
