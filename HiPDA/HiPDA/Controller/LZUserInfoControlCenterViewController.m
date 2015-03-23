//
//  LZUserInfoControlCenterViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZUserInfoControlCenterViewController.h"
#import "LZNetworkHelper.h"
#import "LZAccount.h"

#define TAG_OVERVIEW 1000

@interface LZUserInfoControlCenterViewController()

@end

@implementation LZUserInfoControlCenterViewController

-(void)viewDidLoad{
    self.view.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];

    
}

-(void)loginComplete:(id)sender{
//    NSLog(@"登录成功！");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)viewDidAppear:(BOOL)animated{
//    NSLog(@"%lf %lf",self.view.frame.size.width,self.view.frame.size.height);
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
    UIView *frontView = nil;
    UINavigationController *frontNC = (UINavigationController *)revealController.frontViewController;
    if (frontNC.viewControllers.count > 1) {
        return;
    } else {
        frontView = frontNC.topViewController.navigationController.view;
    }
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        
        UIView *existingOverView = (UIView *)[frontView viewWithTag:TAG_OVERVIEW];
        if (!existingOverView) {
            UIView *overView = [[UIView alloc]initWithFrame:frontView.bounds];
            overView.tag = TAG_OVERVIEW;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
            [overView addGestureRecognizer:tap];
            existingOverView = overView;
        }
        [frontView addSubview:existingOverView];

    }
    else {
        UIView *existingOverView = (UIView *)[frontView viewWithTag:TAG_OVERVIEW];
        if (existingOverView) {
            [existingOverView removeFromSuperview];
            
        }
    }
}
@end
