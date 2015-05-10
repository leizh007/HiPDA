//
//  LZHAccount.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHAccount.h"
#import "SSKeychain.h"
#import <UIKit/UIKit.h>
#import "LZHNetworkFetcher.h"

NSString* const LZHACCOUNTUSERPASSWORDD=@"LZHACCOUNTUSERPASSWORDD";
NSString* const LZHACCOUNTUSERNAME=@"LZHACCOUNTUSERNAME";
NSString* const LZHACCOUNTUSERUID=@"LZHACCOUNTUSERUID";
NSString* const LZHACCOUNTUSERAVATAR=@"LZHACCOUNTUSERAVATAR";
NSString* const LZHACCOUNTSERVICE=@"LZHACCOUNTSERVICE";
NSString* const LZHACCOUNTQUESTIONID=@"LZHACCOUNTQUESTIONID";
NSString* const LZHACCOUNTQUESTIONANSWER=@"LZHACCOUNTQUESTIONANSWER";

@interface LZHAccount()

@end

@implementation LZHAccount

+(id)sharedAccount{
    static LZHAccount *account=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (account==nil) {
            account=[[LZHAccount alloc]init];
        }
    });
    return account;
}

-(id)init{
    if (self=[super init]) {
        
    }
    return self;
}

-(BOOL)hasValideAccount{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:LZHACCOUNTUSERNAME]!=nil&&[userDefaults objectForKey:LZHACCOUNTUSERNAME]!=[NSNull null]) {
        return YES;
    }
    return NO;
}

-(id)account{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userName=[userDefaults objectForKey:LZHACCOUNTUSERNAME];
    NSString *password=[SSKeychain passwordForService:LZHACCOUNTSERVICE account:userName];
    NSString *questionid=[userDefaults objectForKey:LZHACCOUNTQUESTIONID];
    NSString *qestionAnswer=[userDefaults objectForKey:LZHACCOUNTQUESTIONANSWER];
    if ([userDefaults objectForKey:LZHACCOUNTUSERUID]!=nil) {
        NSString *uid=[userDefaults objectForKey:LZHACCOUNTUSERUID];
        UIImage *avatar=[UIImage imageWithData:[userDefaults objectForKey:LZHACCOUNTUSERAVATAR]];
        return @{LZHACCOUNTUSERNAME:userName,
                 LZHACCOUNTUSERPASSWORDD:password,
                 LZHACCOUNTUSERUID:uid,
                 LZHACCOUNTUSERAVATAR:avatar,
                 LZHACCOUNTQUESTIONID:questionid,
                 LZHACCOUNTQUESTIONANSWER:qestionAnswer};
    }else{
        return @{LZHACCOUNTUSERNAME:userName,
                LZHACCOUNTUSERPASSWORDD:password,
                LZHACCOUNTUSERUID:[NSNull null],
                LZHACCOUNTUSERAVATAR:[NSNull null],
                LZHACCOUNTQUESTIONID:questionid,
                LZHACCOUNTQUESTIONANSWER:qestionAnswer};
    }
    
}

-(void)setAccount:(id)account{
    NSDictionary *info=(NSDictionary *)account;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:info[LZHACCOUNTUSERNAME] forKey:LZHACCOUNTUSERNAME];
    [userDefaults setObject:info[LZHACCOUNTUSERUID] forKey:LZHACCOUNTUSERUID];
    if ([info objectForKey:LZHACCOUNTUSERAVATAR]!=nil) {
        [userDefaults setObject:UIImagePNGRepresentation((UIImage *)info[LZHACCOUNTUSERAVATAR]) forKey:LZHACCOUNTUSERAVATAR];
    }else{
        [userDefaults removeObjectForKey:LZHACCOUNTUSERAVATAR];
    }
    [SSKeychain setPassword:info[LZHACCOUNTUSERPASSWORDD] forService:LZHACCOUNTSERVICE account:info[LZHACCOUNTUSERNAME]];
    if ([info objectForKey:LZHACCOUNTQUESTIONID]!=nil) {
        [userDefaults setObject:info[LZHACCOUNTQUESTIONID] forKey:LZHACCOUNTQUESTIONID];
    }else{
        [userDefaults removeObjectForKey:LZHACCOUNTQUESTIONID];
    }
    [userDefaults setObject:info[LZHACCOUNTQUESTIONANSWER] forKey:LZHACCOUNTQUESTIONANSWER];
//    NSLog(@"账户保存成功");
    [[NSNotificationCenter defaultCenter]postNotificationName:LZHUSERINFOLOADCOMPLETENOTIFICATION object:nil];
    [userDefaults synchronize];
}

@end
