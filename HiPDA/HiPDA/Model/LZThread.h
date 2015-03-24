//
//  LZThread.h
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LZUser;

@interface LZThread : NSObject<NSCoding>

@property (assign, nonatomic) NSInteger fid;
@property (strong, nonatomic) NSString  *tid;
@property (strong, nonatomic) NSString  *title;
@property (strong, nonatomic) LZUser    *user;
@property (assign, nonatomic) BOOL      hasRead;
@property (nonatomic, strong) NSString  *dateString;
@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, assign) NSInteger replyCount;
@property (nonatomic, assign) NSInteger openCount;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) BOOL      hasImage;
@property (nonatomic, assign) BOOL      hasAttach;


-(id)initWithAttributes:(NSDictionary *)attributes;

@end
