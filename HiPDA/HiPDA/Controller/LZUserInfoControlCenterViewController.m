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
#import "LZUserInfoControlCenterView.h"
#import "LZUser.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define TAG_OVERVIEW 1000

@interface LZUserInfoControlCenterViewController()

@property (strong, nonatomic) LZUserInfoControlCenterView *lZUserInfoControlCenterView;

@end

@implementation LZUserInfoControlCenterViewController

-(void)viewDidLoad{
    self.revealViewController.delegate=self;
}

-(id)init{
    self=[super init];
    if (self) {
        self.lZUserInfoControlCenterView=[[LZUserInfoControlCenterView alloc]initWithFrame:self.view.frame];
        self.view=self.lZUserInfoControlCenterView;
    }
    return self;
}

-(void)loginComplete:(id)sender{
//    NSLog(@"登录成功！");
    NSArray *accountArray=[[LZAccount sharedAccount]getAccountInfo];
    self.lZUserInfoControlCenterView.userNameLabel.text=accountArray[0];
    LZUser *user=[[LZUser alloc] initWithAttributes:@{@"uid":[NSNumber numberWithInteger:[(NSString *)[[LZAccount sharedAccount] getAccountUid] integerValue]],
                                                      @"userName":[[LZAccount sharedAccount]getAccountInfo][0]}];
    self.lZUserInfoControlCenterView.userNameLabel.text=user.userName;
    [self.lZUserInfoControlCenterView.avatarImageView sd_setImageWithURL:user.avatarImageUrl];
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
