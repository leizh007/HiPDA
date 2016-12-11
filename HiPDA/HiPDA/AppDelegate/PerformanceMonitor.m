//
//  PerformanceMonitor.m
//  HiPDA
//
//  Created by leizh007 on 2016/12/11.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

#import "PerformanceMonitor.h"
#import <CrashReporter/CrashReporter.h>

/// http://www.tanhao.me/code/151113.html/
@interface PerformanceMonitor()

/// 超时次数
@property(nonatomic, assign) NSInteger timeouCount;

/// 观察者
@property(nonatomic, assign) CFRunLoopObserverRef observer;

/// 信号量
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

/// 活动类型
@property(nonatomic, assign) CFRunLoopActivity activity;

@end

@implementation PerformanceMonitor

/// runLoop回调函数
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    PerformanceMonitor *monitor = (__bridge PerformanceMonitor *)info;
    monitor.activity = activity;
    dispatch_semaphore_signal(monitor.semaphore);
}
#pragma clang diagnostic pop

- (void)start {
#ifdef DEBUG
    NSLog(@"INFO: PerformanceMonitor Server started.");
    if (self.observer) {
        return;
    }
    
    // 信号量
    self.semaphore = dispatch_semaphore_create(0);
    
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = { 0, (__bridge void *)self, NULL, NULL };
    self.observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                            kCFRunLoopAllActivities,
                                            YES,
                                            0,
                                            &runLoopObserverCallBack,
                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), self.observer, kCFRunLoopCommonModes);
    
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            long status = dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC));
            if (status != 0) {
                if (!self.observer) {
                    self.timeouCount = 0;
                    self.semaphore = nil;
                    self.activity = 0;
                    return;
                }
                
                if (self.activity == kCFRunLoopBeforeSources || self.activity == kCFRunLoopAfterWaiting) {
                    self.timeouCount += 1;
                    if (self.timeouCount < 5) {
                        continue;
                    }
                    
                    PLCrashReporterConfig *config = [[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll];
                    PLCrashReporter *crashReporter = [[PLCrashReporter alloc] initWithConfiguration:config];
                    
                    NSData *data = [crashReporter generateLiveReport];
                    PLCrashReport *report = [[PLCrashReport alloc] initWithData:data error:nil];
                    NSString *reportLog = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];
                    NSLog(@"------------\n%@\n------------", reportLog);
                    self.timeouCount = 0;
                }
            }
        }
    });
#endif
}

- (void)stop {
#ifdef DEBUG
    if (!self.observer) {
        return;
    }
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, kCFRunLoopCommonModes);
    CFRelease(self.observer);
    self.observer = NULL;
#endif
}

+ (instancetype)shared {
    static PerformanceMonitor *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[PerformanceMonitor alloc] init];
    });
    
    return _shared;
}

@end
