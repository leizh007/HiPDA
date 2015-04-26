//
//  LZHMemCPViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMemCPViewController.h"
#import "MTLog.h"
#import "LZNotice.h"

@interface LZHMemCPViewController ()

@end

@implementation LZHMemCPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blueColor];
}


#pragma mark - Notification

-(void)handleNotification:(NSNotification *)notification{
//    NSLog(@"%@",notification.name); 
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sumPromptPm"]) {
//        NSLog(@"%ld",[[LZNotice shareNotice] sumPromptPm]);
    }
}

#pragma mark - SWRevealViewControllerDelegate
/**
 *  当rearview出现的时候禁止frontview的触控
 *
 *  @param revealController revealController
 *  @param position         当position为FrontViewPositionRight时才禁止
 */
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        UIView *lockingView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView setTag:1000];
        [revealController.frontViewController.view addSubview:lockingView];
    }
    else
        [[revealController.frontViewController.view viewWithTag:1000] removeFromSuperview];
}


@end
