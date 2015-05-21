//
//  LZHSendPmViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LZHSendPmViewControllDelegate <NSObject>

-(void)didFinishEdittingMessage:(NSString *)message isSend:(BOOL)send;

@end

@interface LZHSendPmViewController : UIViewController

@property (weak, nonatomic) id<LZHSendPmViewControllDelegate> delegate;

@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *sendButton;

@end
