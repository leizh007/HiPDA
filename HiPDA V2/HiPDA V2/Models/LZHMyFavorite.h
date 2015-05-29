//
//  LZHMyFavorites.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZHNetworkFetcher.h"

@interface LZHMyFavorite : NSObject

@property (copy, nonatomic) NSString *URLString;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *fidName;
@property (copy, nonatomic) NSString *replyCount;

+(void)getMyFavoritesInPage:(NSInteger)page completionHandler:(LZHNetworkFetcherCompletionHandler)completion;

@end
