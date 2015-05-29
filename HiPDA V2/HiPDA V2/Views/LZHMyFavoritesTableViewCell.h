//
//  LZHMyFavoritesTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHMyFavorite;

@interface LZHMyFavoritesTableViewCell : UITableViewCell

-(void)configureMyFavorites:(LZHMyFavorite *)myFavorites;

+(CGFloat)cellHeightForMyFavorites:(LZHMyFavorite *)myFavorits;

@end
