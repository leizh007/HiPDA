//
//  UIImage+LZHHIPDA.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/13.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "UIImage+LZHHIPDA.h"
#import "CustomBadge.h"

@implementation UIImage (LZHHIPDA)

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+(UIImage *)segmentedImageWithTitle:(NSString *)title badgeValue:(NSInteger)value{
    UIView *contentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 88, 31)];
    contentView.backgroundColor=[UIColor colorWithRed:0.924 green:0.924 blue:0.924 alpha:1];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.text=title;
    titleLabel.frame=CGRectMake(8, 10, 68, 21);
    titleLabel.backgroundColor=[UIColor colorWithRed:0.924 green:0.924 blue:0.924 alpha:1];
    [contentView addSubview:titleLabel];
    CustomBadge *badge=[CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%ld",value] withScale:0.8];
    badge.frame=CGRectMake(63, 0, 20, 20);
    if (value==0) {
        badge.hidden=YES;
    }
    [contentView addSubview:badge];
    return [UIImage imageWithView:contentView];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
