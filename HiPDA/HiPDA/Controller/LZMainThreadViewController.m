//
//  LZMainThreadViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZMainThreadViewController.h"
#import "SWRevealViewController.h"
#import "UIBarButtonItem+ImageItem.h"
#import "BBBadgeBarButtonItem.h"
#import "LZNetworkHelper.h"

@interface LZMainThreadViewController()

@property (assign, nonatomic) NSInteger fid;

@end

@implementation LZMainThreadViewController

-(void)viewDidLoad{
    self.view.backgroundColor=[UIColor greenColor];
    SWRevealViewController *revealViewController=[self revealViewController];
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    
    UIImage *leftBarButtonItemImage=[UIImage imageNamed:@"leftBarButtonItemImage"];
    UIButton *button=[[UIButton alloc] init];
    [button setImage:leftBarButtonItemImage forState:UIControlStateNormal];
    button.bounds=CGRectMake(0, 0, leftBarButtonItemImage.size.width, leftBarButtonItemImage.size.height);
    [button addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    BBBadgeBarButtonItem *barButton=[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    barButton.badgeValue=@"0";
    self.navigationItem.leftBarButtonItem=barButton;

    self.fid=DISCOVERYSECTIONFID;
    [[LZNetworkHelper sharedLZNetworkHelper] loadForumFid:self.fid page:1 success:^(NSArray *threads) {
        
    } failure:^(NSError *error) {
        
    }];
}

@end
