//
//  LZHSetting.h
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZHSetting : NSObject

+(id)sharedSetting;

@property (strong, nonatomic) NSString *fontName;

@end
