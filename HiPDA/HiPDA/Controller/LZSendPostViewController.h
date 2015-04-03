//
//  LZSendPostViewController.h
//  HiPDA
//
//  Created by leizh007 on 15/4/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZSendPostView.h"
#import "LZPost.h"

@interface LZSendPostViewController : UIViewController

@property (strong, nonatomic) NSString *navTitle;
@property (assign, nonatomic) POSTTYPE postType;
@property (assign, nonatomic) NSInteger fid;
@property (strong, nonatomic) NSString *tid;
@property (strong, nonatomic) LZPost *post;

@end
