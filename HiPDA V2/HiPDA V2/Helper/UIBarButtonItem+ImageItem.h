//
//  UIBarButtonItem+ImageItem.h
//  UIKitConvenience
//
//  Created by Eric Goldberg on 6/8/12.
//  Copyright (c) 2012 Eric Goldberg. All rights reserved.
//

// This is influenced by http://stackoverflow.com/questions/2681321/uibarbuttonitem-with-custom-image-and-no-border


#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ImageItem)

+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
