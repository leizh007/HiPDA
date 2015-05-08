//
//  LZHProfileViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/6.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHProfileViewController.h"
#import "LZHUser.h"

@interface LZHProfileViewController ()

@end

@implementation LZHProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor greenColor];
    NSLog(@"userName:%@ uid:%@",_user.userName,_user.uid);
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

@end
