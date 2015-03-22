//
//  LZNetworkHelper.m
//  HiPDA
//
//  Created by leizh007 on 15/3/22.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZNetworkHelper.h"
#import "SVProgressHUD.h"
#import <AFNetworking.h>
#import "NSString+extension.h"


@interface LZNetworkHelper()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation LZNetworkHelper

+(id)sharedLZNetworkHelper{
    static LZNetworkHelper *networkHelper=nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        networkHelper=[[LZNetworkHelper alloc]init];
    });
    return networkHelper;
}

-(id)init{
    self=[super init];
    self.manager=[AFHTTPRequestOperationManager manager];
    [self.manager.requestSerializer setValue:@"www.hi-pda.com" forHTTPHeaderField:@"Host"];
    [self.manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.91 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.manager.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self.manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language" ];
    [self.manager.requestSerializer setValue:@"http://www.hi-pda.com/forum/forumdisplay.php?fid=2" forHTTPHeaderField:@"Referer"];
    self.manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    return self;
}


-(void)getFormhash{
    [self.manager GET:@"http://www.hi-pda.com/forum/logging.php?action=login"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"%@",[NSString encodingGBKStringToIOSString:responseObject]);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error:%@",error);
         }];
}

@end
