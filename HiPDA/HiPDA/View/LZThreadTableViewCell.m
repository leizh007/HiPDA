//
//  LZThreadTableViewCell.m
//  HiPDA
//
//  Created by leizh007 on 15/3/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZThreadTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define INSETBETWEENVIEWELEMENTS 8
#define AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT 34
#define SMLLLABELFONTSIZE 15
#define BIGLABELFONTSIZE 18
#define HEADANDFOOTLABELHEIGHT 1

@interface LZThreadTableViewCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *headLabel;
@property (strong, nonatomic) UILabel *footLabel;

@end

@implementation LZThreadTableViewCell{
    CGFloat cellWidth;
    CGFloat avatarImageViewCenterY;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellWidth=[[UIScreen mainScreen]bounds].size.width;
        self.avatarImageView=[[UIImageView alloc]init];
        self.userNameLabel=[[UILabel alloc]init];
        self.countLabel=[[UILabel alloc]init];
        self.timeLabel=[[UILabel alloc]init];
        self.titleLabel=[[UILabel alloc]init];
        self.headLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, cellWidth, HEADANDFOOTLABELHEIGHT)];
        self.footLabel=[[UILabel alloc]init];
        [self.contentView addSubview:self.headLabel];
        [self.contentView addSubview:self.footLabel];
        self.headLabel.backgroundColor=[UIColor colorWithRed:0.899 green:0.899 blue:0.899 alpha:1];
        self.footLabel.backgroundColor=[UIColor colorWithRed:0.899 green:0.899 blue:0.899 alpha:1];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.userNameLabel];
        [self.contentView addSubview:self.countLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.titleLabel];
        self.avatarImageView.layer.cornerRadius=15.0f;
        [self.avatarImageView.layer setMasksToBounds:YES];
        self.avatarImageView.layer.borderWidth=1.0f;
        self.avatarImageView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        self.avatarImageView.frame=CGRectMake(INSETBETWEENVIEWELEMENTS, INSETBETWEENVIEWELEMENTS+HEADANDFOOTLABELHEIGHT, AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT, AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT);
        avatarImageViewCenterY=self.avatarImageView.frame.origin.y+AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT/2;
        self.avatarImageView.backgroundColor=[UIColor colorWithRed:0.84 green:0.837 blue:0.847 alpha:0.6];
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        self.contentView.backgroundColor=[UIColor lightGrayColor];
    }else{
        self.contentView.backgroundColor=[UIColor whiteColor];
    }
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image=nil;
}

-(void)configure:(LZThread *)thread{
    [self.avatarImageView sd_setImageWithURL:thread.user.avatarImageUrl];
    self.userNameLabel.text=thread.user.userName;
    self.userNameLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:SMLLLABELFONTSIZE];
    self.userNameLabel.textColor=[UIColor colorWithRed:1 green:0.622 blue:0 alpha:1];
    [self.userNameLabel sizeToFit];
    self.timeLabel.text=[self timeAgoToDate:thread.date];
    self.timeLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:SMLLLABELFONTSIZE];
    self.timeLabel.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
    [self.timeLabel sizeToFit];
    self.countLabel.text=[NSString stringWithFormat:@"%ld/%ld",(long)thread.replyCount,(long)thread.openCount];
    self.countLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:SMLLLABELFONTSIZE];
    self.countLabel.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
    [self.countLabel sizeToFit];
    self.titleLabel.text=thread.title;
    if (thread.hasImage) {
        self.titleLabel.text=[NSString stringWithFormat:@"%@🎑",thread.title];
    }
    if (thread.hasAttach) {
        self.titleLabel.text=[NSString stringWithFormat:@"%@📎",thread.title];
    }
    self.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:BIGLABELFONTSIZE];
    self.titleLabel.numberOfLines=0;
    self.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    self.titleLabel.textColor=[UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1];
    if (thread.hasRead) {
        self.userNameLabel.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
        self.titleLabel.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
    }else{
        NSMutableAttributedString *countAttributedString=[[NSMutableAttributedString alloc]initWithString:self.countLabel.text];
        NSDictionary *attributes=@{NSForegroundColorAttributeName:[UIColor redColor]};
        [countAttributedString addAttributes:attributes range:NSMakeRange(0, [[NSString stringWithFormat:@"%ld",(long)thread.replyCount] length])];
        self.countLabel.attributedText=countAttributedString;
    }
}

-(void)layoutSubviews{
    self.userNameLabel.frame=CGRectMake(2*INSETBETWEENVIEWELEMENTS+AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT, avatarImageViewCenterY-self.userNameLabel.frame.size.height/2, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height);
    self.timeLabel.frame=CGRectMake(cellWidth-INSETBETWEENVIEWELEMENTS-self.timeLabel.frame.size.width, avatarImageViewCenterY-self.timeLabel.frame.size.height/2, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height);
    self.countLabel.frame=CGRectMake(self.timeLabel.frame.origin.x-INSETBETWEENVIEWELEMENTS-self.countLabel.frame.size.width, avatarImageViewCenterY-self.countLabel.frame.size.height/2, self.countLabel.frame.size.width, self.countLabel.frame.size.height);
    CGSize sizeToExpect=[self.titleLabel sizeThatFits:CGSizeMake(cellWidth-2*INSETBETWEENVIEWELEMENTS, 9999)];
    self.titleLabel.frame=CGRectMake(INSETBETWEENVIEWELEMENTS, self.avatarImageView.frame.origin.y+AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT+INSETBETWEENVIEWELEMENTS, sizeToExpect.width, sizeToExpect.height);
    self.footLabel.frame=CGRectMake(0, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+INSETBETWEENVIEWELEMENTS, cellWidth, HEADANDFOOTLABELHEIGHT);
}

+(CGFloat)getCellHeight:(LZThread *)thread{
    UILabel *label=[[UILabel alloc]init];
    label.font=[UIFont fontWithName:@"HelveticaNeue" size:BIGLABELFONTSIZE];
    label.text=thread.title;
    label.text=thread.title;
    if (thread.hasImage) {
        label.text=[NSString stringWithFormat:@"%@🎑",thread.title];
    }
    if (thread.hasAttach) {
        label.text=[NSString stringWithFormat:@"%@📎",thread.title];
    }
    label.numberOfLines=0;
    label.lineBreakMode=NSLineBreakByCharWrapping;
    CGSize sizeToExpect=[label sizeThatFits:CGSizeMake([[UIScreen mainScreen]bounds].size.width-2*INSETBETWEENVIEWELEMENTS, 9999)];
    return sizeToExpect.height+INSETBETWEENVIEWELEMENTS*3+AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT+2*HEADANDFOOTLABELHEIGHT;
}


- (NSString *)timeAgoToDate:(NSDate *)date
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaMinutes < (24 * 60))
    {
        return @"今天";
    }
    else if (deltaMinutes < (24 * 60 * 2))
    {
        return @"昨天";
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:@"%d天前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 14))
    {
        return @"上周";
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:@"%d周前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 61))
    {
        return @"上个月";
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:@"%d月前",minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731))
    {
        return @"去年";
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [NSString stringWithFormat:@"%d年前",minutes];
}


@end
