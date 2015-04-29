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

-(BOOL)isUserNameInBlackList:(NSString *)userName;

-(void)addUserNameToBlackList:(NSString *)userName;

-(void)removeUserNameFromBlackList:(NSString *)userName;

@end
