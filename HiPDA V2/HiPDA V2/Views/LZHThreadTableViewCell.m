//
//  LZHThreadTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/26.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHThreadTableViewCell.h"
#import "LZHUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZHThread.h"
#import "LZHSetting.h"

static const CGFloat kAvatarImageViewSize=34.0;
static const CGFloat kDistanceBetweenViews=8.0;
static const CGFloat kSmallFontSize=15.0;
static const CGFloat kBigFontSize=18.0;
static const CGFloat kAvatarImageViewCornerRadius=15.0;
static const CGFloat kAvatarImageViewBorderWidth=1.0;
static const CGFloat kSeperatorHeight=1.0;

#define kLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define kDeepWordsColor [UIColor blackColor]
#define kSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]

@interface LZHThreadTableViewCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UILabel *postTimeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *headSeperatorLabel;
@property (strong, nonatomic) UILabel *footSeperatorLabel;

@end

@implementation LZHThreadTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _avatarImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAvatarImageViewSize, kAvatarImageViewSize)];
        _avatarImageView.layer.cornerRadius=kAvatarImageViewCornerRadius;
        _avatarImageView.layer.masksToBounds=YES;
        _avatarImageView.layer.borderWidth=kAvatarImageViewBorderWidth;
        _avatarImageView.layer.borderColor=[kLightWordsColor CGColor];
        _userNameLabel=[[UILabel alloc]init];
        _userNameLabel.font=[UIFont fontWithName:[[LZHSetting sharedSetting]fontName] size:kSmallFontSize];
        _userNameLabel.textColor=kLightWordsColor;
        _countLabel=[[UILabel alloc]init];
        _countLabel.textColor=kLightWordsColor;
        _countLabel.font=[UIFont fontWithName:[[LZHSetting sharedSetting]fontName] size:kSmallFontSize];
        _postTimeLabel=[[UILabel alloc]init];
        _postTimeLabel.textColor=kLightWordsColor;
        _postTimeLabel.font=[UIFont fontWithName:[[LZHSetting sharedSetting]fontName] size:kSmallFontSize];
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont fontWithName:[[LZHSetting sharedSetting] fontName] size: kBigFontSize];
        _headSeperatorLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kSeperatorHeight)];
        _footSeperatorLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kSeperatorHeight)];
        _headSeperatorLabel.backgroundColor=kSeperatorColor;
        _footSeperatorLabel.backgroundColor=kSeperatorColor;
        _headSeperatorLabel.translatesAutoresizingMaskIntoConstraints=NO;
        _footSeperatorLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_avatarImageView];
        [self.contentView addSubview:_userNameLabel];
        [self.contentView addSubview:_countLabel];
        [self.contentView addSubview:_postTimeLabel];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_headSeperatorLabel];
        [self.contentView addSubview:_footSeperatorLabel];
        
    }
    return self;
}

-(id)configureThread:(LZHThread *)thread{
    [_avatarImageView sd_setImageWithURL:thread.user.avatarImageURL];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints=NO;
    _userNameLabel.text=thread.user.userName;
    [_userNameLabel sizeToFit];
    _userNameLabel.translatesAutoresizingMaskIntoConstraints=NO;
    _countLabel.text=[NSString stringWithFormat:@"%ld/%ld",thread.replyCount,thread.totalCount];
    [_countLabel sizeToFit];
    _countLabel.translatesAutoresizingMaskIntoConstraints=NO;
    _postTimeLabel.text=thread.postTime;
    [_postTimeLabel sizeToFit];
    _postTimeLabel.translatesAutoresizingMaskIntoConstraints=NO;
    _titleLabel.text=thread.title;
    _titleLabel.numberOfLines=0;
    _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    CGSize optSize=[_titleLabel sizeThatFits:CGSizeMake(self.contentView.frame.size.width-2*kDistanceBetweenViews, 99999)];
    _titleLabel.frame=CGRectMake(0, 0, optSize.width, optSize.height);
    _titleLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [self configureViewConstrains];
    return self;
}

-(void)configureViewConstrains{
    //_headSeperatorLabel
    NSLayoutConstraint *headConstrainX=[NSLayoutConstraint constraintWithItem:_headSeperatorLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *headConstrainY=[NSLayoutConstraint constraintWithItem:_headSeperatorLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *headConstrainWidth=[NSLayoutConstraint constraintWithItem:_headSeperatorLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_headSeperatorLabel.frame.size.width];
    NSLayoutConstraint *headConstrainHeight=[NSLayoutConstraint constraintWithItem:_headSeperatorLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:kSeperatorHeight];
    [self.contentView addConstraints:@[headConstrainX,headConstrainY,headConstrainWidth,headConstrainHeight]];
    
    //_avatarImageView
    NSLayoutConstraint *avatarConstrainX=[NSLayoutConstraint constraintWithItem:_avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kDistanceBetweenViews];
    NSLayoutConstraint *avatarConstrainY=[NSLayoutConstraint constraintWithItem:_avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_headSeperatorLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kDistanceBetweenViews];
    NSLayoutConstraint *avatarConstrainWidth=[NSLayoutConstraint constraintWithItem:_avatarImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:kAvatarImageViewSize];
    NSLayoutConstraint *avatarConstrainHeight=[NSLayoutConstraint constraintWithItem:_avatarImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:kAvatarImageViewSize];
    [self.contentView addConstraints:@[avatarConstrainX,avatarConstrainY,avatarConstrainWidth,avatarConstrainHeight]];
    
    //_userNameLabel
    NSLayoutConstraint *userNameConstrainX=[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:kDistanceBetweenViews];
    NSLayoutConstraint *userNameConstrainY=[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *userNameConstrainWidth=[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_userNameLabel.frame.size.width];
    NSLayoutConstraint *userNameConstrainHeight=[NSLayoutConstraint constraintWithItem:_userNameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_userNameLabel.frame.size.height];
    [self.contentView addConstraints:@[userNameConstrainX,userNameConstrainY,userNameConstrainWidth,userNameConstrainHeight]];
    
    //_postTimeLabel
    NSLayoutConstraint *postTimeConstrainX=[NSLayoutConstraint constraintWithItem:_postTimeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-kDistanceBetweenViews-_postTimeLabel.frame.size.width];
    NSLayoutConstraint *postTimeConstrainY=[NSLayoutConstraint constraintWithItem:_postTimeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *postTimeConstrainWidth=[NSLayoutConstraint constraintWithItem:_postTimeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_postTimeLabel.frame.size.width];
    NSLayoutConstraint *postTimeConstrainHeight=[NSLayoutConstraint constraintWithItem:_postTimeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_postTimeLabel.frame.size.height];
    [self.contentView addConstraints:@[postTimeConstrainX,postTimeConstrainY,postTimeConstrainWidth,postTimeConstrainHeight]];
    
    //_countLabel
    NSLayoutConstraint *countConstrainX=[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_postTimeLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-kDistanceBetweenViews-_countLabel.frame.size.width];
    NSLayoutConstraint *countConstrainY=[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *countConstrainWidth=[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_countLabel.frame.size.width];
    NSLayoutConstraint *countConstrainHeight=[NSLayoutConstraint constraintWithItem:_countLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_countLabel.frame.size.height];
    [self.contentView addConstraints:@[countConstrainX,countConstrainY,countConstrainWidth,countConstrainHeight]];
    
    //_titleLabel
    NSLayoutConstraint *titleConstrainX=[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *titleConstrainY=[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_avatarImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kDistanceBetweenViews];
    NSLayoutConstraint *titleConstrainWidth=[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_titleLabel.frame.size.width];
    NSLayoutConstraint *titleConstrainHeight=[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_titleLabel.frame.size.height];
    [self.contentView addConstraints:@[titleConstrainX,titleConstrainY,titleConstrainWidth,titleConstrainHeight]];
    
    //_footSeperatorLabel
    NSLayoutConstraint *footConstrainX=[NSLayoutConstraint constraintWithItem:_footSeperatorLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *footConstrainY=[NSLayoutConstraint constraintWithItem:_footSeperatorLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kDistanceBetweenViews];
    NSLayoutConstraint *footConstrainWidth=[NSLayoutConstraint constraintWithItem:_footSeperatorLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_footSeperatorLabel.frame.size.width];
    NSLayoutConstraint *footConstrainHeight=[NSLayoutConstraint constraintWithItem:_footSeperatorLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:kSeperatorHeight];
    NSLayoutConstraint *footConstrainBottom=[NSLayoutConstraint constraintWithItem:_footSeperatorLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.contentView addConstraints:@[footConstrainX,footConstrainY,footConstrainWidth,footConstrainHeight,footConstrainBottom]];
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_avatarImageView sd_cancelCurrentImageLoad];
    _avatarImageView.image=nil;
//    [self.contentView removeConstraints:self.contentView.constraints];
}
@end
