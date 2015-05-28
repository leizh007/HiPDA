//
//  LZHMyPostsTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/28.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyPostsTableViewCell.h"
#import "LZHMyPosts.h"

const CGFloat LZHMyPostsSmallFontSize=16.0;
const CGFloat LZHMyPostsBigFontSize=18.0;
const CGFloat LZHMyPostsDistanceBetweenViews=8.0f;

#define LZHMyPostsLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define LZHMyPostsDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071  alpha:1.0]
#define LZHMyPostsBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]
#define LZHMyPostsSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86     alpha:1]
#define LZHMyPostsViewWidth [[UIScreen mainScreen]bounds].size.width

@interface LZHMyPostsTableViewCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *postTimeLabel;
@property (strong, nonatomic) UILabel *fidNameLabel;
@property (strong, nonatomic) UILabel *postContentLabel;
@property (strong, nonatomic) UILabel *seperatorLabel;

@end

@implementation LZHMyPostsTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor=LZHMyPostsBackgroundColor;
        
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont systemFontOfSize:LZHMyPostsBigFontSize];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        _postTimeLabel=[[UILabel alloc]init];
        _postTimeLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
        _postTimeLabel.textColor=LZHMyPostsLightWordsColor;
        
        _fidNameLabel=[[UILabel alloc]init];
        _fidNameLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
        _fidNameLabel.textColor=LZHMyPostsLightWordsColor;
        
        _postContentLabel=[[UILabel alloc]init];
        _postContentLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
        _postContentLabel.numberOfLines=0;
        _postContentLabel.lineBreakMode=NSLineBreakByCharWrapping;
        _postContentLabel.textColor=LZHMyPostsLightWordsColor;
        
        _seperatorLabel=[[UILabel alloc]init];
        _seperatorLabel.backgroundColor=LZHMyPostsSeperatorColor;
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_postTimeLabel];
        [self.contentView addSubview:_fidNameLabel];
        [self.contentView addSubview:_postContentLabel];
        [self.contentView addSubview:_seperatorLabel];
    }
    return self;
}


-(void)configureMyPosts:(LZHMyPosts *)myPosts{
    _postTimeLabel.text=myPosts.postTime;
    [_postTimeLabel sizeToFit];
    _postTimeLabel.frame=CGRectMake(LZHMyPostsViewWidth-LZHMyPostsDistanceBetweenViews-_postTimeLabel.frame.size.width, LZHMyPostsDistanceBetweenViews, _postTimeLabel.frame.size.width, _postTimeLabel.frame.size.height);
    
    _fidNameLabel.text=myPosts.fidName;
    [_fidNameLabel sizeToFit];
    _fidNameLabel.frame=CGRectMake(LZHMyPostsViewWidth-LZHMyPostsDistanceBetweenViews-_fidNameLabel.frame.size.width, _postTimeLabel.frame.origin.y+_postTimeLabel.frame.size.height+LZHMyPostsDistanceBetweenViews, _fidNameLabel.frame.size.width, _fidNameLabel.frame.size.height);
    
    CGFloat labelLength=_postTimeLabel.frame.size.width>_fidNameLabel.frame.size.width?_postTimeLabel.frame.size.width:_fidNameLabel.frame.size.width;
    
    _titleLabel.text=myPosts.title;
    CGSize optimalTitleLabelSize=[_titleLabel sizeThatFits:CGSizeMake(LZHMyPostsViewWidth-3*LZHMyPostsDistanceBetweenViews-labelLength, 9999)];
    _titleLabel.frame=CGRectMake(LZHMyPostsDistanceBetweenViews, LZHMyPostsDistanceBetweenViews, optimalTitleLabelSize.width, optimalTitleLabelSize.height);
    
    _postContentLabel.text=myPosts.postContent;
    CGSize optimalPostContentLabelSize=[_postContentLabel sizeThatFits:CGSizeMake(LZHMyPostsViewWidth-3*LZHMyPostsDistanceBetweenViews-labelLength, 9999)];
    _postContentLabel.frame=CGRectMake(LZHMyPostsDistanceBetweenViews, _titleLabel.frame.size.height+_titleLabel.frame.origin.y+LZHMyPostsDistanceBetweenViews, optimalPostContentLabelSize.width, optimalPostContentLabelSize.height);
    
    _seperatorLabel.frame=CGRectMake(LZHMyPostsDistanceBetweenViews, _postContentLabel.frame.origin.y+_postContentLabel.frame.size.height+LZHMyPostsDistanceBetweenViews, LZHMyPostsViewWidth-LZHMyPostsDistanceBetweenViews, 1.0f);
}

+(CGFloat)cellHeightForMyPosts:(LZHMyPosts *)myPosts{
    UILabel *postTimeLabel=[[UILabel alloc]init];
    postTimeLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
    postTimeLabel.text=myPosts.postTime;
    [postTimeLabel sizeToFit];
    
    UILabel *fidNameLabel=[[UILabel alloc]init];
    fidNameLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
    fidNameLabel.text=myPosts.fidName;
    [fidNameLabel sizeToFit];
    
    CGFloat labelLength=postTimeLabel.frame.size.width>fidNameLabel.frame.size.width?postTimeLabel.frame.size.width:fidNameLabel.frame.size.width;
    
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.numberOfLines=0;
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.font=[UIFont systemFontOfSize:LZHMyPostsBigFontSize];
    titleLabel.text=myPosts.title;
    
    CGSize optimalTitleLabelSize=[titleLabel sizeThatFits:CGSizeMake(LZHMyPostsViewWidth-3*LZHMyPostsDistanceBetweenViews-labelLength, 9999)];
    
    UILabel *postContentLabel=[[UILabel alloc]init];
    postContentLabel.font=[UIFont systemFontOfSize:LZHMyPostsSmallFontSize];
    postContentLabel.numberOfLines=0;
    postContentLabel.lineBreakMode=NSLineBreakByCharWrapping;
    postContentLabel.text=myPosts.postContent;
    
    CGSize optimalPostContentSize=[postContentLabel sizeThatFits:CGSizeMake(LZHMyPostsViewWidth-3*LZHMyPostsDistanceBetweenViews-labelLength, 9999)];
    
    return 4*LZHMyPostsDistanceBetweenViews+optimalTitleLabelSize.height+optimalPostContentSize.height+1.0f;
}

@end
