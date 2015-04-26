//
//  LZHBlackList.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZHBlackList : NSObject

+(id)sharedBlackList;

-(BOOL)isUIDInBlackList:(NSString *)uid;

-(void)addUIDToBlackList:(NSString *)uid;

-(void)removeUIDFromBlackList:(NSString *)uid;

@end
