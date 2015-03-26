//
//  LZPersistenceDataManager.h
//  HiPDA
//
//  Created by leizh007 on 15/3/24.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZPersistenceDataManager : NSObject

+(id)sharedPersistenceDataManager;
-(void)addThreadTidToHasRead:(NSString *)tid;
-(void)storeHasReadThreads;
-(BOOL)hasReadThreadTid:(NSString *)tid;

@end
