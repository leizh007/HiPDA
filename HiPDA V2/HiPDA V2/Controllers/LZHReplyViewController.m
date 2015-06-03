//
//  LZHReplyViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/6/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHReplyViewController.h"

@interface LZHReplyViewController ()

@end

@implementation LZHReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arrangeViews];
}

#pragma mark - View

-(void)arrangeViews {
    self.view.backgroundColor=[UIColor whiteColor];
    switch (self.replyType) {
        case LZHReplyTypeNewTopic: {
            self.title=@"发表新帖";
            break;
        }
        case LZHreplyTypeNewPost: {
            self.title=@"发表回复";
            break;
        }
        case LZHReplyTypeReply: {
            self.title=[NSString stringWithFormat:@"回复#%@",_pid];
            break;
        }
        case LZHReplyTypeQuote: {
            self.title=[NSString stringWithFormat:@"引用#%@",_pid];
            break;
        }
    }
    
    UIBarButtonItem *cancelBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem=cancelBarButtonItem;
}

#pragma mark - Button Pressed

-(void)cancelButtonPressed:(UIButton *)button {
    __weak typeof(self) weakSelf=self;
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"放弃" message:@"是否真的放弃编辑？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
