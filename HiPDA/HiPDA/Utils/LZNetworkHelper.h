//
//  LZNetworkHelper.h
//  HiPDA
//
//  Created by leizh007 on 15/3/22.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface LZNetworkHelper : NSObject

+(id)sharedLZNetworkHelper;
-(void)login:(NSDictionary *)parameters block: (void (^)(BOOL isSuccess,NSError *error))block;
-(void)loadForumFid:(NSInteger)fid page:(NSInteger)page success:(void (^)(NSArray *threads))success failure:(void (^)(NSError *error))failure;
@end