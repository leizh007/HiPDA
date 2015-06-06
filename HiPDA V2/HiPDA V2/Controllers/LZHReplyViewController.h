//
//  LZHReplyViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/6/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LZHReplyType){
    LZHReplyTypeNewTopic,
    LZHreplyTypeNewPost,
    LZHReplyTypeReply,
    LZHReplyTypeQuote
};


@interface LZHReplyViewController : UIViewController

@property (copy, nonatomic) NSString *fid;
@property (assign, nonatomic) NSInteger page;
@property (copy, nonatomic) NSString *pid;
@property (assign, nonatomic) LZHReplyType replyType;
@property (copy, nonatomic) NSString *tid;

@end
