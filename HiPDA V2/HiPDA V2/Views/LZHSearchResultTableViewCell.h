//
//  LZHSearchResultTableViewCell.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/29.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZHSearchResult;

@interface LZHSearchResultTableViewCell : UITableViewCell

-(void)configureSearchResult:(LZHSearchResult *)searchResult;
+(CGFloat)cellHeightForSearchResult:(LZHSearchResult*)searchResult;

@end
