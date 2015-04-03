//
//  AppDelegate.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "AppDelegate.h"
#import "LZAccount.h"
#import "LZLoginViewController.h"
#import "LZNetworkHelper.h"
#import "SVProgressHUD.h"
#import <AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "SDURLCache.h"
#import "SWRevealViewController.h"
#import "LZMainThreadViewController.h"
#import "LZUserInfoControlCenterViewController.h"
#import "LZPersistenceDataManager.h"
#import "LZCache.h"
#import "LZThread.h"
#import "LZUser.h"
#import "NSString+extension.h"

@interface AppDelegate ()

@property (strong, nonatomic) LZMainThreadViewController *mainThreadViewController;
@property (strong, nonatomic) LZUserInfoControlCenterViewController *userInfoControlCenterViewController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                         diskCapacity:1024*1024*5 // 5MB disk cache
                                                             diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    self.mainThreadViewController=[[LZMainThreadViewController alloc]init];
    UINavigationController *frontNavController=[[UINavigationController alloc]initWithRootViewController:self.mainThreadViewController] ;
    self.userInfoControlCenterViewController=[[LZUserInfoControlCenterViewController alloc]init];
    self.viewController=[[SWRevealViewController alloc]initWithRearViewController:self.userInfoControlCenterViewController frontViewController:frontNavController];
    self.viewController.rearViewRevealWidth=REARVIEWREVEALWIDTH;
    self.viewController.rearViewRevealOverdraw=REARVIEWREVEALOVERDRAW;
    self.window.rootViewController=self.viewController;
    [self.window makeKeyAndVisible];
    self.viewController.delegate=self.userInfoControlCenterViewController;
    self.userInfoControlCenterViewController.mainThreadViewController=self.mainThreadViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.userInfoControlCenterViewController
                                             selector:@selector(loginComplete:)
                                                 name:LOGINCOMPLETENOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.mainThreadViewController selector:@selector(getNotifications:) name:FORUMTHREADSISGETTINGNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.mainThreadViewController selector:@selector(getNotifications:) name:FORUMTHREADSISEXTRACTINGNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.mainThreadViewController selector:@selector(getNotifications:) name:LOGINCOMPLETENOTIFICATION object:nil];
    [[LZAccount sharedAccount] checkAccountIfNoValidThenLogin:self.window.rootViewController];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[LZAccount sharedAccount] saveCookies];
    [[LZPersistenceDataManager sharedPersistenceDataManager]storeHasReadThreads];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LZAccount sharedAccount] loadCookies];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[LZPersistenceDataManager sharedPersistenceDataManager]storeHasReadThreads];
    [[NSNotificationCenter defaultCenter]removeObserver:self.userInfoControlCenterViewController];
    [[NSNotificationCenter defaultCenter]removeObserver:self.mainThreadViewController];
}

@end
