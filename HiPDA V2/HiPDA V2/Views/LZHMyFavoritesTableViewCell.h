//
//  LZHMyFavoritesTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHMyFavorites;

@interface LZHMyFavoritesTableViewCell : UITableViewCell

-(void)configureMyFavorites:(LZHMyFavorites *)myFavorites;

+(CGFloat)cellHeightForMyFavorites:(LZHMyFavorites *)myFavorits;

@end
