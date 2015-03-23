//
//  LZUserInfoControlCenterViewController.h
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface LZUserInfoControlCenterViewController : UIViewController<SWRevealViewControllerDelegate>

-(void)loginComplete:(id)sender;

@end
