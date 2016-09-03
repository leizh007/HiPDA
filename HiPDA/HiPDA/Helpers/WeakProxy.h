//
//  WeakProxy.h
//  HiPDA
//
//  Created by leizh007 on 16/8/24.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 代理，用来持有对象的弱引用
 */
@interface WeakProxy : NSProxy

NS_ASSUME_NONNULL_BEGIN

/**
 代理目标对象
 */
@property (nonatomic, weak, readonly) id<NSObject> target;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 对目标对象创建一个代理

 @param target 目标对象

 @return 返回新建的代理
 */
- (instancetype)initWithTarget:(id<NSObject>)target NS_SWIFT_NAME(init(_:)) NS_DESIGNATED_INITIALIZER;

/**
 对目标对象创建一个代理

 @param target 目标对象

 @return 返回新建的代理
 */
+ (instancetype)proxyWithTarget:(id<NSObject>)target NS_SWIFT_NAME(proxy(_:));

NS_ASSUME_NONNULL_END

@end
