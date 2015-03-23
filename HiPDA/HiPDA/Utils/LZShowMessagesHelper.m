//
//  LZShowMessagesHelper.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZShowMessagesHelper.h"

@interface LZShowMessagesHelper()

@end

@implementation LZShowMessagesHelper

/**
 *  显示SVPROGRESSHUD，两秒后自动消失
 *
 *  @param type SVPROGRESSHUD类型
 *  @param msg  显示的信息
 */
+(void)showProgressHUDType:(int)type message:(NSString *)msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case SVPROGRESSHUDTYPENONE:
                [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];
                break;
            case SVPROGRESSHUDTYPEPROGRESS:
                [SVProgressHUD showProgress:0.5 status:msg maskType:SVProgressHUDMaskTypeGradient];
                break;
            case SVPROGRESSHUDTYPESUCCESS:
                [SVProgressHUD showSuccessWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];
                break;
            case SVPROGRESSHUDTYPEERROR:
                [SVProgressHUD showErrorWithStatus:msg maskType:SVProgressHUDMaskTypeGradient];
                break;
            default:
                break;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    
}


@end
