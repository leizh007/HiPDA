//
//  LZHReadList.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZHReadList : NSObject

+(id)sharedReadList;

-(BOOL)hasReadTid:(NSString *)tid;

-(void)addTid:(NSString *)tid;

@end
