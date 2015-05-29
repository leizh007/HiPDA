//
//  LZHMyFavoritesTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyFavoritesTableViewCell.h"
#import "LZHMyFavorite.h"

static const CGFloat LZHMyFavoritesSmallFontSize=16.0;
static const CGFloat LZHMyFavoritesBigFontSize=18.0;
static const CGFloat LZHMyFavoritesDistanceBetweenViews=8.0f;

#define LZHMyFavoritesLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define LZHMyFavoritesDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071  alpha:1.0]
#define LZHMyFavoritesBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]
#define LZHMyFavoritesSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86     alpha:1]
#define LZHMyFavoritesViewWidth [[UIScreen mainScreen]bounds].size.width

@interface LZHMyFavoritesTableViewCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *fidNameLabel;
@property (strong, nonatomic) UILabel *replyCountLabel;
@property (strong, nonatomic) UILabel *seperatorLabel;

@end

@implementation LZHMyFavoritesTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont systemFontOfSize:LZHMyFavoritesBigFontSize];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        _fidNameLabel=[[UILabel alloc]init];
        _fidNameLabel.font=[UIFont systemFontOfSize:LZHMyFavoritesSmallFontSize];
        _fidNameLabel.textColor=LZHMyFavoritesLightWordsColor;
        
        _replyCountLabel=[[UILabel alloc]init];
        _replyCountLabel.font=[UIFont systemFontOfSize:LZHMyFavoritesSmallFontSize];
        _replyCountLabel.textColor=LZHMyFavoritesLightWordsColor;
        
        _seperatorLabel=[[UILabel alloc]init];
        _seperatorLabel.backgroundColor=LZHMyFavoritesSeperatorColor;
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_fidNameLabel];
        [self.contentView addSubview:_replyCountLabel];
        [self.contentView addSubview:_seperatorLabel];
    }
    return self;
}

-(void)configureMyFavorites:(LZHMyFavorite *)myFavorites{
    _fidNameLabel.text=myFavorites.fidName;
    [_fidNameLabel sizeToFit];
    _fidNameLabel.frame=CGRectMake(LZHMyFavoritesViewWidth-LZHMyFavoritesDistanceBetweenViews-_fidNameLabel.frame.size.width, LZHMyFavoritesDistanceBetweenViews, _fidNameLabel.frame.size.width, _fidNameLabel.frame.size.height);
    
    _replyCountLabel.text=myFavorites.replyCount;
    [_replyCountLabel sizeToFit];
    _replyCountLabel.frame=CGRectMake(_fidNameLabel.frame.origin.x-LZHMyFavoritesDistanceBetweenViews-_replyCountLabel.frame.size.width, LZHMyFavoritesDistanceBetweenViews, _replyCountLabel.frame.size.width, _replyCountLabel.frame.size.height);
    
    _titleLabel.text=myFavorites.title;
    CGSize optimalTitleLabelSize=[_titleLabel sizeThatFits:CGSizeMake(LZHMyFavoritesViewWidth-2*LZHMyFavoritesDistanceBetweenViews, 9999)];
    _titleLabel.frame=CGRectMake(LZHMyFavoritesDistanceBetweenViews, _replyCountLabel.frame.origin.y+_replyCountLabel.frame.size.height+LZHMyFavoritesDistanceBetweenViews, optimalTitleLabelSize.width, optimalTitleLabelSize.height);
    
    _seperatorLabel.frame=CGRectMake(LZHMyFavoritesDistanceBetweenViews, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+LZHMyFavoritesDistanceBetweenViews, LZHMyFavoritesViewWidth-LZHMyFavoritesDistanceBetweenViews, 1.0f);
}

+(CGFloat)cellHeightForMyFavorites:(LZHMyFavorite *)myFavorits{
    UILabel *fidNameLabel=[[UILabel alloc]init];
    fidNameLabel.font=[UIFont systemFontOfSize:LZHMyFavoritesSmallFontSize];
    fidNameLabel.text=myFavorits.fidName;
    [fidNameLabel sizeToFit];
    
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.font=[UIFont systemFontOfSize:LZHMyFavoritesBigFontSize];
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.numberOfLines=0;
    titleLabel.text=myFavorits.title;
    CGSize optimalTitleLabelSize=[titleLabel sizeThatFits:CGSizeMake(LZHMyFavoritesViewWidth-2*LZHMyFavoritesDistanceBetweenViews, 9999)];
    
    return 3*LZHMyFavoritesDistanceBetweenViews+fidNameLabel.frame.size.height+optimalTitleLabelSize.height+1.0f;
}

@end
