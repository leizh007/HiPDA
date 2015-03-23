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

@interface LZMainThreadViewController()

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
//    NSLog(@"%lf %lf",leftBarButtonItemImage.size.width,leftBarButtonItemImage.size.height );
    button.bounds=CGRectMake(0, 0, leftBarButtonItemImage.size.width, leftBarButtonItemImage.size.height);
//    [button setBackgroundColor:[UIColor blueColor]];
    [button addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    BBBadgeBarButtonItem *barButton=[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    barButton.badgeValue=@"0";
    self.navigationItem.leftBarButtonItem=barButton;
//    NSLog(@"%@",@"test");
}

@end
