//
//  LZHAddFavorite.h
//  HiPDA V2
//
//  Created by leizh007 on 15/6/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

@interface LZHAddFavorite : NSObject

+(void)addFavoriteTid:(NSString *)tid completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
