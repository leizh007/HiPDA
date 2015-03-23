//
//  LZMainThreadViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZMainThreadViewController.h"
#import "SWRevealViewController.h"

@interface LZMainThreadViewController()

@end

@implementation LZMainThreadViewController

-(void)viewDidLoad{
    self.view.backgroundColor=[UIColor greenColor];
    SWRevealViewController *revealViewController=[self revealViewController];
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
}

@end
