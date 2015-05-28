//
//  LZHMyThreadsTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyThreadsTableViewCell.h"
#import "LZHMyThreads.h"

const CGFloat LZHMyThreadsSmallFontSize=16.0;
const CGFloat LZHMyThreadsBigFontSize=18.0;
const CGFloat LZHMyThreadsDistanceBetweenViews=13.0f;

#define LZHMyThreadsLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define LZHMyThreadsDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071  alpha:1.0]
#define LZHMyThreadsBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]
#define LZHMyThreadsSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86     alpha:1]
#define LZHMyThreadsViewWidth [[UIScreen mainScreen]bounds].size.width

@interface LZHMyThreadsTableViewCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *fidNameLabel;
@property (strong, nonatomic) UILabel *seperatorLabel;

@end

@implementation LZHMyThreadsTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor=LZHMyThreadsBackgroundColor;
        
        _titleLabel=[[UILabel alloc]init];
        _fidNameLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont systemFontOfSize:LZHMyThreadsBigFontSize];
        _fidNameLabel.font=[UIFont systemFontOfSize:LZHMyThreadsSmallFontSize];
        _fidNameLabel.textColor=LZHMyThreadsLightWordsColor;
        _seperatorLabel=[[UILabel alloc]init];
        _seperatorLabel.backgroundColor=LZHMyThreadsSeperatorColor;
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_fidNameLabel];
        [self.contentView addSubview:_seperatorLabel];
    }
    return self;
}

-(void)configureMyThreads:(LZHMyThreads *)myThread{
    _titleLabel.text=myThread.title;
    _fidNameLabel.text=myThread.fidName;
}

-(void)layoutSubviews{
    [_fidNameLabel sizeToFit];
    _fidNameLabel.frame=CGRectMake(LZHMyThreadsViewWidth-LZHMyThreadsDistanceBetweenViews-_fidNameLabel.frame.size.width, LZHMyThreadsDistanceBetweenViews, _fidNameLabel.frame.size.width, _fidNameLabel.frame.size.height);
    
    CGSize opticalTitleLableSize=[_titleLabel sizeThatFits:CGSizeMake(LZHMyThreadsViewWidth-3*LZHMyThreadsDistanceBetweenViews-_fidNameLabel.frame.size.width, 9999)];
    _titleLabel.frame=CGRectMake(LZHMyThreadsDistanceBetweenViews, LZHMyThreadsDistanceBetweenViews, opticalTitleLableSize.width, opticalTitleLableSize.height);
    
    _seperatorLabel.frame=CGRectMake(LZHMyThreadsDistanceBetweenViews,_titleLabel.frame.size.height+_titleLabel.frame.origin.y+LZHMyThreadsDistanceBetweenViews , LZHMyThreadsViewWidth-LZHMyThreadsDistanceBetweenViews, 1.0f);
}

+(CGFloat)cellHeightForMyThreads:(LZHMyThreads *)myThread{
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.text=myThread.title;
    titleLabel.numberOfLines=0;
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.font=[UIFont systemFontOfSize:LZHMyThreadsBigFontSize];
    
    UILabel *fidNameLabel=[[UILabel alloc]init];
    fidNameLabel.text=myThread.fidName;
    fidNameLabel.font=[UIFont systemFontOfSize:LZHMyThreadsSmallFontSize];
    [fidNameLabel sizeToFit];
    
    CGSize opticalTitleLabelSize=[titleLabel sizeThatFits:CGSizeMake(LZHMyThreadsViewWidth-3*LZHMyThreadsDistanceBetweenViews-fidNameLabel.frame.size.width, 9999)];
    
    return LZHMyThreadsDistanceBetweenViews*2+opticalTitleLabelSize.height+1.0f;
}

@end
