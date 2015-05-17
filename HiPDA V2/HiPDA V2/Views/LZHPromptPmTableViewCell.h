//
//  LZHPromptPmTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/16.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHPrompt;

@interface LZHPromptPmTableViewCell : UITableViewCell

-(id)configurePrompt:(LZHPrompt *)prompt;

+(CGFloat)cellHeightForPrompt:(LZHPrompt *)prompt;

@end
