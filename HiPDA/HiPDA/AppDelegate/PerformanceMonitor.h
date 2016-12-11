//
//  PerformanceMonitor.h
//  HiPDA
//
//  Created by leizh007 on 2016/12/11.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 性能监控
@interface PerformanceMonitor : NSObject

/// 单例
+ (instancetype)shared;

/// 开始监控
- (void)start;

/// 结束监控
- (void)stop;

@end
