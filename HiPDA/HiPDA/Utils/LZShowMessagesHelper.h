//
//  LZShowMessagesHelper.h
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

#define SVPROGRESSHUDTYPENONE     1
#define SVPROGRESSHUDTYPEPROGRESS 2
#define SVPROGRESSHUDTYPESUCCESS  3
#define SVPROGRESSHUDTYPEERROR    4

@interface LZShowMessagesHelper : NSObject

+(void)showProgressHUDType:(int)type message:(NSString *)msg;

@end
