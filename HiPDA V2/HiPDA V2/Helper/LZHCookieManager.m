//
//  LZHCookieManager.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHCookieManager.h"

NSString *const LZHHIPDACOOKIES=@"LZHHIPDACOOKIES";

@interface LZHCookieManager()

@end

@implementation LZHCookieManager

/**
 *  保存cookie
 */
+(void)saveCookies{
    NSData *cookieData=[NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]];
    NSUserDefaults *accountDefaults=[NSUserDefaults standardUserDefaults];
    [accountDefaults setObject:cookieData forKey:LZHHIPDACOOKIES];
    [accountDefaults synchronize];
}

/**
 *  加载cookie
 */
+(void)loadCookies{
    NSArray *cookieArray=[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:LZHHIPDACOOKIES] ];
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieArray) {
        [cookieStorage setCookie:cookie];
    }
}

/**
 *  清楚cookie
 */
+(void)clearCookies{
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        [cookieStorage deleteCookie:cookie];
    }
}


@end
