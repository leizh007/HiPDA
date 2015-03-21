//
//  LZAccount.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZAccount.h"
#import "SSKeychain.h"
#import "NSString+extension.h"

#define HiPDAUserName @"HiPDAUserName"
#define HiPDAServiceName @"HiPDAServiceName"
#define AHiPDANewUser @"AHiPDANewUser"

@implementation LZAccount

/**
 *  LZAccount的单例
 *
 *  @return LZAccount的一个实例
 */
+(id)sharedAccount{
    static LZAccount *account=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        account=[[LZAccount alloc]init];
    });
    return account;
}

/**
 *  检查是否存在一个可用的账户
 *
 *  @return 存在为真否则为假
 */
-(BOOL)checkIfThereIsAValidAccount{
    NSArray *accountInfo=[[LZAccount sharedAccount]getAccountInfo];
    if ([accountInfo[0] isEqualToString:AHiPDANewUser]) {
        return NO;
    }
    return YES;
}



/**
 *  返回账户信息
 *
 *  @return 用户名，密码，安全提问，回答
 */
-(id)getAccountInfo{
    NSUserDefaults *accontDefaults=[NSUserDefaults standardUserDefaults];
    NSString *accountName=[accontDefaults objectForKey:HiPDAUserName] ;
    if (accountName==nil) {
        accountName=AHiPDANewUser;
    }
    NSString *password=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAUserName account:[NSString stringWithFormat:@"%@+password",accountName]]];
    NSString *safeQuestionNumber=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAUserName account:[NSString stringWithFormat:@"%@+safeQuestionNumber",accountName]]];
    NSString *safeQuestionAnswear=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAUserName account:[NSString stringWithFormat:@"%@+safeQuestionAnswear",accountName]]];
    NSArray *info=@[accountName,password,safeQuestionNumber,safeQuestionAnswear];
    return info;
    
}

@end
