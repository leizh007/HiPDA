//
//  LZHPostViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZHPostViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSString *tid;
//直接对_page赋值不会调用setPage:方法
@property (assign, nonatomic) NSInteger page;

@property (copy, nonatomic) NSString *pid;

@property (assign, nonatomic) BOOL isRedirect;

@property (copy, nonatomic) NSString *URLString;

@end
