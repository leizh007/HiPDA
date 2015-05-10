//
//  LZHAccount.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LZHACCOUNTUSERNAME;
extern NSString *const LZHACCOUNTUSERUID;
extern NSString *const LZHACCOUNTUSERAVATAR;
extern NSString *const LZHACCOUNTUSERPASSWORDD;
extern NSString *const LZHACCOUNTQUESTIONID;
extern NSString *const LZHACCOUNTQUESTIONANSWER;

@interface LZHAccount : NSObject

+(instancetype)sharedAccount;

/**
 *  获取用户信息，包括用户名，UID，头像，密码（md5加密后的字符串），问题id，问题答案
 *
 *  @return NSDictionary
 */
-(id)account;

/**
 *   设置账户
 *
 *  @param account NSDictionary 用户名，密码（md5加密后的字符串），UID，头像，问题id，问题答案
 */
-(void)setAccount:(id)account;

/**
 *  检测是否有可用的账户
 *
 *  @return BOOL
 */
-(BOOL)hasValideAccount;

@end
