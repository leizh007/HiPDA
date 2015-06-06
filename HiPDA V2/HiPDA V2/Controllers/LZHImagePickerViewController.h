//
//  LZHImagePickerViewController.h
//  HiPDA V2
//
//  Created by leizh007 on 15/6/6.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LZHImagePickerViewControllerDelegate <NSObject>

-(void)didFinishImagePick:(NSArray *)response;

@end

@interface LZHImagePickerViewController : UIViewController

@property (weak, nonatomic) id<LZHImagePickerViewControllerDelegate> delegate;

@end

