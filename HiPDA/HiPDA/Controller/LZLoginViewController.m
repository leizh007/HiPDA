//
//  LZLoginViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZLoginViewController.h"
#import "LZLoginView.h"

@interface LZLoginViewController ()

@property (strong, nonatomic) LZLoginView *loginView;

@end

@implementation LZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView=[[LZLoginView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view=self.loginView;
    [self.loginView.safeQuestionNumberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.loginButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)buttonPressed:(id)sender{
//    NSLog(@"%d button pressed!",(int)((UIButton *)sender).tag);
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.4];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:1.0];
                     }];
    
}
@end
