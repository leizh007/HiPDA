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
#import "LZLoginViewController.h"

#define HiPDAUserName @"HiPDAUserName"
#define HiPDAServiceName @"HiPDAServiceName"
#define AHiPDANewUser @"AHiPDANewUser"
#define HiPDAUserCookies @"HiPDAUserCookies"

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
    NSString *password=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+password",accountName]]];
    NSString *safeQuestionNumber=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+safeQuestionNumber",accountName]]];
    NSString *safeQuestionAnswear=[NSString ifTheStringIsNilReturnAEmptyString:[SSKeychain passwordForService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+safeQuestionAnswear",accountName]]];
    NSArray *info=@[accountName,password,safeQuestionNumber,safeQuestionAnswear];
    return info;
    
}

/**
 *  设置用户信息
 *
 *  @param info 用户名，密码，安全提问，回答
 *
 *  @return 设置成功返回真否则为假
 */
-(BOOL)setAccountInfo:(NSArray *)info{
    NSUserDefaults *accountDefaults=[NSUserDefaults standardUserDefaults];
    [accountDefaults setObject:info[0] forKey:HiPDAUserName];
    if (![SSKeychain setPassword:info[1] forService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+password",info[0]]]|
        ![SSKeychain setPassword:info[2] forService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+safeQuestionNumber",info[0]]]|![SSKeychain setPassword:info[3] forService:HiPDAServiceName account:[NSString stringWithFormat:@"%@+safeQuestionAnswear",info[0]]]) {
        return NO;
    }
    [accountDefaults synchronize];
    [[LZAccount sharedAccount] saveCookies];
    return YES;
}

/**
 *  保存cookie
 */
-(void)saveCookies{
    NSData *cookieData=[NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]];
    NSUserDefaults *accountDefaults=[NSUserDefaults standardUserDefaults];
    [accountDefaults setObject:cookieData forKey:HiPDAUserCookies];
    [accountDefaults synchronize];
}

/**
 *  加载cookie
 */
-(void)loadCookies{
    NSArray *cookieArray=[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:HiPDAUserCookies] ];
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieArray) {
        [cookieStorage setCookie:cookie];
    }
}

/**
 *  清楚cookie
 */
-(void)clearCookies{
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}

/**
 *  检查是否有可用账户，若没有就转到登录页面
 *
 *  @param viewController 根viewcontroller
 */
-(void)checkAccountIfNoValidThenLogin:(UIViewController *)viewController{
    if (![[LZAccount sharedAccount]checkIfThereIsAValidAccount]) {
        LZLoginViewController *loginViewController=[[LZLoginViewController alloc]init];
        loginViewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        [viewController presentViewController:loginViewController animated:YES completion:^{
        }];
    }
}
@end
