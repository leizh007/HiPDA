//
//  LZSendPostView.h
//  HiPDA
//
//  Created by leizh007 on 15/4/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZNetworkHelper.h"

@interface LZSendPostView : UIView

@property (assign, nonatomic) POSTTYPE postType;
@property (strong, nonatomic) UIButton *classificationButton;
@property (strong, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) UITextView *contentTextView;

@end
