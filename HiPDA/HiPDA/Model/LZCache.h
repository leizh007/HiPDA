//
//  LZCache.h
//  HiPDA
//
//  Created by leizh007 on 15/3/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOCache.h"

@interface LZCache : NSObject

+(id)globalCache;
-(void)cacheForum:(NSArray *)threads fid:(NSInteger)fid page:(NSInteger)page;
-(NSArray *)loadForumCacheFid:(NSInteger)fid page:(NSInteger)page;

@end
