//
//  UIImage+LZHHIPDA.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/13.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LZHHIPDA)

+(UIImage *)segmentedImageWithTitle:(NSString *)title badgeValue:(NSInteger)value;

+ (UIImage *)imageWithColor:(UIColor *)color ;

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

@end
