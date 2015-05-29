//
//  LZHSearchResultTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/29.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSearchResultTableViewCell.h"
#import "LZHSearchResult.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZHUser.h"

static const CGFloat LZHSearchResultSmallFontSize=16.0;
static const CGFloat LZHSearchResultBigFontSize=18.0;
static const CGFloat LZHSearchResultDistanceBetweenViews=8.0f;
static const CGFloat LZHSearchResultAvatarImageViewSize=34.0;

#define LZHSearchResultLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define LZHSearchResultDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071  alpha:1.0]
#define LZHSearchResultBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]
#define LZHSearchResultSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86     alpha:1]
#define LZHSearchResultViewWidth [[UIScreen mainScreen]bounds].size.width

@interface LZHSearchResultTableViewCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *postTimeLabel;
@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *seperatorLabel;

@end

@implementation LZHSearchResultTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor=LZHSearchResultBackgroundColor;
        
        _avatarImageView=[[UIImageView alloc]init];
        _avatarImageView.frame=CGRectMake(0, 0, LZHSearchResultAvatarImageViewSize, LZHSearchResultAvatarImageViewSize);
        _avatarImageView.layer.borderWidth=1.0f;
        _avatarImageView.layer.borderColor=[LZHSearchResultSeperatorColor CGColor];
        _avatarImageView.layer.cornerRadius=15.0f;
        _avatarImageView.layer.masksToBounds=YES;
        
        _userNameLabel=[[UILabel alloc]init];
        _userNameLabel.font=[UIFont systemFontOfSize:LZHSearchResultSmallFontSize];
        _userNameLabel.textColor=LZHSearchResultLightWordsColor;
        
        _postTimeLabel=[[UILabel alloc]init];
        _postTimeLabel.font=[UIFont systemFontOfSize:LZHSearchResultSmallFontSize];
        _postTimeLabel.textColor=LZHSearchResultLightWordsColor;
        
        _countLabel=[[UILabel alloc]init];
        _countLabel.font=[UIFont systemFontOfSize:LZHSearchResultSmallFontSize];
        _countLabel.textColor=LZHSearchResultLightWordsColor;
        
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont systemFontOfSize:LZHSearchResultBigFontSize];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        _seperatorLabel=[[UILabel alloc]init];
        _seperatorLabel.backgroundColor=LZHSearchResultSeperatorColor;
        
        [self.contentView addSubview:_avatarImageView];
        [self.contentView addSubview:_userNameLabel];
        [self.contentView addSubview:_postTimeLabel];
        [self.contentView addSubview:_countLabel];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_seperatorLabel];
    }
    return self;
}

-(void)configureSearchResult:(LZHSearchResult *)searchResult{
    [_avatarImageView sd_setImageWithURL:searchResult.uesr.avatarImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    _avatarImageView.frame=CGRectMake(LZHSearchResultDistanceBetweenViews, LZHSearchResultDistanceBetweenViews, LZHSearchResultAvatarImageViewSize, LZHSearchResultAvatarImageViewSize);
    
    _userNameLabel.text=searchResult.uesr.userName;
    [_userNameLabel sizeToFit];
    _userNameLabel.frame=CGRectMake(_avatarImageView.frame.origin.x+_avatarImageView.frame.size.width+LZHSearchResultDistanceBetweenViews, _avatarImageView.frame.origin.y+_avatarImageView.frame.size.height/2-_userNameLabel.frame.size.height/2, _userNameLabel.frame.size.width, _userNameLabel.frame.size.height);
    
    _postTimeLabel.text=searchResult.postTime;
    [_postTimeLabel sizeToFit];
    _postTimeLabel.frame=CGRectMake(LZHSearchResultViewWidth-LZHSearchResultDistanceBetweenViews-_postTimeLabel.frame.size.width, _userNameLabel.frame.origin.y, _postTimeLabel.frame.size.width, _postTimeLabel.frame.size.height);
    
    _countLabel.text=[NSString stringWithFormat:@"%@/%@",searchResult.replyCount,searchResult.openCount];
    [_countLabel sizeToFit];
    _countLabel.frame=CGRectMake(_postTimeLabel.frame.origin.x-LZHSearchResultDistanceBetweenViews-_countLabel.frame.size.width, _postTimeLabel.frame.origin.y, _countLabel.frame.size.width, _countLabel.frame.size.height);

    _titleLabel.attributedText=searchResult.attributedTitle;
    
    CGSize optimalTitleLabelSize=[_titleLabel sizeThatFits:CGSizeMake(LZHSearchResultViewWidth-2*LZHSearchResultDistanceBetweenViews, 9999)];
    _titleLabel.frame=CGRectMake(LZHSearchResultDistanceBetweenViews, _avatarImageView.frame.origin.y+_avatarImageView.frame.size.height+LZHSearchResultDistanceBetweenViews, optimalTitleLabelSize.width, optimalTitleLabelSize.height);
    
    _seperatorLabel.frame=CGRectMake(LZHSearchResultDistanceBetweenViews, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+LZHSearchResultDistanceBetweenViews, LZHSearchResultViewWidth-LZHSearchResultDistanceBetweenViews, 1.0f);
    
}

+(CGFloat)cellHeightForSearchResult:(LZHSearchResult *)searchResult{
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.numberOfLines=0;
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.font=[UIFont systemFontOfSize:LZHSearchResultBigFontSize];
    titleLabel.attributedText=searchResult.attributedTitle;
    
    CGSize optimalTitleLabelSize=[titleLabel sizeThatFits:CGSizeMake(LZHSearchResultViewWidth-2*LZHSearchResultDistanceBetweenViews, 9999)];
    
    return 3*LZHSearchResultDistanceBetweenViews+LZHSearchResultAvatarImageViewSize+optimalTitleLabelSize.height+1.0f;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_avatarImageView sd_cancelCurrentImageLoad];
    _avatarImageView.image=nil;
}

@end
