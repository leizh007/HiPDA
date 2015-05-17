//
//  LZHPromptPmTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/16.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPromptPmTableViewCell.h"
#import "LZHUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZHPrompt.h"
#import "LZHSettings.h"

static const CGFloat kAvatarImageViewSize=34.0;
static const CGFloat kDistanceBetweenViews=8.0;
static const CGFloat kSmallFontSize=15.0;
static const CGFloat kBigFontSize=18.0;
static const CGFloat kAvatarImageViewCornerRadius=15.0;
static const CGFloat kAvatarImageViewBorderWidth=1.0;
static const CGFloat kSeperatorHeight=1.0;

#define kLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define kDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071 alpha:1.0]
#define kSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]
#define kMainScreenWidth [[UIScreen mainScreen]bounds].size.width
#define kBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]

@interface LZHPromptPmTableViewCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *postTimeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *headSeperatorLabel;
@property (strong, nonatomic) UILabel *footSeperatorLabel;

@end

@implementation LZHPromptPmTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds=YES;
        self.backgroundColor=kBackgroundColor;
        _avatarImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kAvatarImageViewSize, kAvatarImageViewSize)];
        _avatarImageView.backgroundColor=[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1];
        _avatarImageView.layer.cornerRadius=kAvatarImageViewCornerRadius;
        _avatarImageView.layer.masksToBounds=YES;
        _avatarImageView.layer.borderWidth=kAvatarImageViewBorderWidth;
        _avatarImageView.layer.borderColor=[kLightWordsColor CGColor];
        _userNameLabel=[[UILabel alloc]init];
        _userNameLabel.font=[UIFont fontWithName:[[LZHSettings sharedSetting]fontName] size:kSmallFontSize];
        _userNameLabel.textColor=kLightWordsColor;
        _postTimeLabel=[[UILabel alloc]init];
        _postTimeLabel.textColor=kLightWordsColor;
        _postTimeLabel.font=[UIFont fontWithName:[[LZHSettings sharedSetting]fontName] size:kSmallFontSize];
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont fontWithName:[[LZHSettings sharedSetting] fontName] size: kBigFontSize];
        _headSeperatorLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kSeperatorHeight)];
        _footSeperatorLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kSeperatorHeight)];
        _headSeperatorLabel.backgroundColor=kSeperatorColor;
        _footSeperatorLabel.backgroundColor=kSeperatorColor;
        [self.contentView addSubview:_avatarImageView];
        [self.contentView addSubview:_userNameLabel];
        [self.contentView addSubview:_postTimeLabel];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_headSeperatorLabel];
        [self.contentView addSubview:_footSeperatorLabel];
    }
    return self;
}

-(id)configurePrompt:(LZHPrompt *)prompt{
    [_avatarImageView sd_setImageWithURL:prompt.user.avatarImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    _userNameLabel.text=prompt.user.userName;
    [_userNameLabel sizeToFit];
    _postTimeLabel.text=prompt.timeString;
    [_postTimeLabel sizeToFit];
    _titleLabel.text=prompt.titleString;
    _titleLabel.numberOfLines=0;
    _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    CGSize optSize=[_titleLabel sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width-2*kDistanceBetweenViews, 99999)];
    _titleLabel.frame=CGRectMake(0, 0, optSize.width, optSize.height);
    if (prompt.isNew) {
        _titleLabel.textColor=[UIColor redColor];
    }else{
        _titleLabel.textColor=kDeepWordsColor;
    }
    _userNameLabel.textColor=[UIColor colorWithRed:1 green:0.622 blue:0 alpha:1];

    return self;
}

-(void)layoutSubviews{
    _headSeperatorLabel.frame=CGRectMake(0, 0, kMainScreenWidth, kSeperatorHeight);
    _avatarImageView.frame=CGRectMake(kDistanceBetweenViews, kDistanceBetweenViews+kSeperatorHeight, kAvatarImageViewSize, kAvatarImageViewSize);
    _userNameLabel.frame=CGRectMake(_avatarImageView.frame.size.width+_avatarImageView.frame.origin.x
                                    +kDistanceBetweenViews, _avatarImageView.frame.origin.y+kAvatarImageViewSize/2-_userNameLabel.frame.size.height/2, _userNameLabel.frame.size.width, _userNameLabel.frame.size.height);
    _postTimeLabel.frame=CGRectMake(kMainScreenWidth-kDistanceBetweenViews-_postTimeLabel.frame.size.width, _userNameLabel.frame.origin.y, _postTimeLabel.frame.size.width, _postTimeLabel.frame.size.height);
    _titleLabel.frame=CGRectMake(kDistanceBetweenViews, _avatarImageView.frame.origin.y+kAvatarImageViewSize+kDistanceBetweenViews, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _footSeperatorLabel.frame=CGRectMake(0, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+kDistanceBetweenViews, _footSeperatorLabel.frame.size.width, _footSeperatorLabel.frame.size.height);
    self.frame=CGRectMake(0, self.frame.origin.y, [[UIScreen mainScreen]bounds].size.width,_footSeperatorLabel.frame.origin.y+_footSeperatorLabel.frame.size.height );
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        self.contentView.backgroundColor=[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    }else{
        self.contentView.backgroundColor=kBackgroundColor;
    }
    
}

+(CGFloat)cellHeightForPrompt:(LZHPrompt *)prompt{
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.text=prompt.titleString;
    titleLabel.numberOfLines=0;
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.font=[UIFont fontWithName:[[LZHSettings sharedSetting] fontName] size: kBigFontSize];
    CGSize optSize=[titleLabel sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width-2*kDistanceBetweenViews, 99999)];
    return kSeperatorHeight*2+3*kDistanceBetweenViews+kAvatarImageViewSize+optSize.height;
}


-(void)prepareForReuse{
    [super prepareForReuse];
    [_avatarImageView sd_cancelCurrentImageLoad];
    _avatarImageView.image=nil;
}


@end
