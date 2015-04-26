//
//  LZHShowMessage.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

typedef NS_ENUM(NSInteger, SVPROGRESSHUDTYPE){
    SVPROGRESSHUDTYPENONE,
    SVPROGRESSHUDTYPEPROGRESS,
    SVPROGRESSHUDTYPESUCCESS,
    SVPROGRESSHUDTYPEERROR
};

@interface LZHShowMessage : NSObject

+(void)showProgressHUDType:(SVPROGRESSHUDTYPE)type message:(NSString *)msg;

@end
