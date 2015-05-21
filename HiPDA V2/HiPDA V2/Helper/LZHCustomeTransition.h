//
//  LZHCustomeTransition.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MZTransition.h"
#import "MZFormSheetController.h"

@interface LZHCustomeTransition : MZTransition

- (void)entryFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;

- (void)exitFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;

@end
