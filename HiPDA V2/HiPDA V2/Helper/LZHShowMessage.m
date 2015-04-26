//
//  LZHShowMessage.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHShowMessage.h"

@implementation LZHShowMessage


+(void)showProgressHUDType:(SVPROGRESSHUDTYPE)type message:(NSString *)msg{
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
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    
}

@end
