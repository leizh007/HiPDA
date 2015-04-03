//
//  LZNetworkHelper.h
//  HiPDA
//
//  Created by leizh007 on 15/3/22.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "LZPost.h"

typedef NS_ENUM(NSInteger, POSTTYPE){
    POSTTYPEREPLY = 0, 
    POSTTYPEQUOTE = 1,
    POSTTYPENEWPOST = 2,
    POSTTYPENEWTHREAD = 3
    
};
@interface LZNetworkHelper : NSObject

+(id)sharedLZNetworkHelper;
-(void)login:(NSDictionary *)parameters block: (void (^)(BOOL isSuccess,NSError *error))block;
-(void)loadForumFid:(NSInteger)fid page:(NSInteger)page success:(void (^)(NSArray *threads))success failure:(void (^)(NSError *error))failure;
-(void)loadPostListTid:(NSString *)tid page:(NSInteger)page isNeedPageFullNumber:(BOOL)isNeed success:(void (^)(NSDictionary *postThreadInfo))success failure:(void (^)(NSError *error))failure;
-(void)sendPostWithTitle:(NSString *)title content:(NSString *)content fid:(NSInteger)fid tid:(NSString *)tid post:(LZPost*)post threadType:(NSInteger)threadType images:(NSArray *)images quoteContent:(NSString *)quoteContent postType:(NSInteger)postType  block:(void (^)(BOOL isSuccess, NSError *error))block;

@end