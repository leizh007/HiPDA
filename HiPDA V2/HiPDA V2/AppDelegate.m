//
//  AppDelegate.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "LZHMemCPViewController.h"
#import "LZHThreadViewController.h"
#import "LZHAccount.h"
#import "LZHLoginViewController.h"
#import "LZHNetworkFetcher.h"
#import "LZHShowMessage.h"
#import <AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "SDURLCache.h"
#import "LZNotice.h"
#import "LZHCookieManager.h"

@interface AppDelegate ()

@property (strong, nonatomic) SWRevealViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    LZHMemCPViewController *memCpViewController=[[LZHMemCPViewController alloc]init];
    LZHThreadViewController *threadViewController=[[LZHThreadViewController alloc]init];
    //注册消息
    [[NSNotificationCenter defaultCenter] addObserver:threadViewController selector:@selector(handleNotification:) name:LZHLOGGINSUCCESSNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:memCpViewController selector:@selector(handleNotification:) name:LZHUSERINFOLOADCOMPLETENOTIFICATION object:nil];
    //注册KVO
    LZNotice *notice=[LZNotice shareNotice];
    [notice addObserver:memCpViewController forKeyPath:@"sumPromptPm" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    UINavigationController *frontViewController=[[UINavigationController alloc]initWithRootViewController:threadViewController];
    _viewController=[[SWRevealViewController alloc]initWithRearViewController:memCpViewController frontViewController:frontViewController];
    _viewController.rearViewRevealWidth=190;
    _viewController.rearViewRevealOverdraw=0;
    _viewController.delegate=memCpViewController;
    self.window.rootViewController=_viewController;
    [self.window makeKeyAndVisible];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                         diskCapacity:1024*1024*5 // 5MB disk cache
                                                             diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    //检查是否存在可用账户，若存在则自动登录，否则转到登录界面
    __weak typeof(self) weakSelf=self;
    dispatch_time_t checkAccountTime=dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100*NSEC_PER_MSEC));
    dispatch_after(checkAccountTime, dispatch_get_main_queue(), ^{
        if ([[LZHAccount sharedAccount]hasValideAccount]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:LZHUSERINFOLOADCOMPLETENOTIFICATION object:nil];
            NSDictionary *userInfo=[[LZHAccount sharedAccount] account];
            [LZHNetworkFetcher loginWithUserName:userInfo[LZHACCOUNTUSERNAME] password:userInfo[LZHACCOUNTUSERPASSWORDD] questionId:userInfo[LZHACCOUNTQUESTIONID] questionAnswer:userInfo[LZHACCOUNTQUESTIONANSWER] completionHandler:^(NSArray *array, NSError *error) {
                if (error==nil) {
                    [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"登录成功!"];
                }else{
                    [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                }
            }];
        }else{
            LZHLoginViewController *loginViewController=[[LZHLoginViewController alloc]init];
            UINavigationController *loginNavigationController=[[UINavigationController alloc]initWithRootViewController:loginViewController];
            [weakSelf.viewController presentViewController:loginNavigationController animated:YES completion:nil];
        }
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [LZHCookieManager saveCookies];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [LZHCookieManager loadCookies];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
