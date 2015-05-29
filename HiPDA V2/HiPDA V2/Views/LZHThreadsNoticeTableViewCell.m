//
//  LZHThreadsNoticeTableViewCell.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/27.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHThreadsNoticeTableViewCell.h"
#import "LZHThreadNotice.h"
#import "LZHUser.h"


const CGFloat LZHThreadsNoticeSmallFontSize=16.0;
const CGFloat LZHThreadsNoticeBigFontSize=18.0;
const CGFloat LZHThreadsNoticeDistanceBetweenViews=8.0f;

#define LZHThreadsNoticeLightWordsColor [UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]
#define LZHThreadsNoticeDeepWordsColor [UIColor colorWithRed:0.071 green:0.071 blue:0.071 alpha:1.0]
#define LZHThreadsNoticeBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]
#define LZHThreadsNoticeSeperatorColor [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1]

@interface LZHThreadsNoticeTableViewCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *postTimeLabel;
@property (strong, nonatomic) UILabel *myReplyLabel;
@property (strong, nonatomic) UILabel *noticeLabel;
@property (assign ,nonatomic) CGFloat viewWidth;
@property (strong, nonatomic) UILabel *seperatorLabel;

@end

@implementation LZHThreadsNoticeTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor=LZHThreadsNoticeBackgroundColor;
        
        _viewWidth=[[UIScreen mainScreen]bounds].size.width;
        
        _seperatorLabel=[[UILabel alloc]init];
        
        _titleLabel=[[UILabel alloc]init];
        _titleLabel.font=[UIFont boldSystemFontOfSize:LZHThreadsNoticeBigFontSize];
        _titleLabel.numberOfLines=0;
        _titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        _postTimeLabel=[[UILabel alloc]init];
        _postTimeLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
        _postTimeLabel.textColor=LZHThreadsNoticeLightWordsColor;
        
        _myReplyLabel=[[UILabel alloc]init];
        _myReplyLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
        _myReplyLabel.numberOfLines=0;
        _myReplyLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        _noticeLabel=[[UILabel alloc]init];
        _noticeLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
        _noticeLabel.numberOfLines=0;
        _noticeLabel.lineBreakMode=NSLineBreakByCharWrapping;
        
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_postTimeLabel];
        [self.contentView addSubview:_myReplyLabel];
        [self.contentView addSubview:_noticeLabel];
        [self.contentView addSubview:_seperatorLabel];
    }
    return self;
}

-(void)configureThreadsNotice:(LZHThreadNotice *)threadsNotice{
    _titleLabel.text=threadsNotice.title;
    _postTimeLabel.text=threadsNotice.postTime;
    _myReplyLabel.text=[NSString stringWithFormat:@"您的帖子：%@",threadsNotice.myReplyContext];
    NSRange replyContentRange=[_myReplyLabel.text rangeOfString:@"您的帖子："];
    NSMutableAttributedString *replyAttributedString=[[NSMutableAttributedString alloc]initWithString:_myReplyLabel.text];
    [replyAttributedString addAttribute:NSForegroundColorAttributeName value:LZHThreadsNoticeLightWordsColor range:NSMakeRange(replyContentRange.length, replyAttributedString.length-replyContentRange.length)];
    _myReplyLabel.attributedText=replyAttributedString;
    if (threadsNotice.noticeType==LZHTHreadsNoticeTypeReply) {
        _noticeLabel.text=[NSString stringWithFormat:@"%@答复您说：%@",threadsNotice.user.userName,threadsNotice.noticeContext];
    }else{
        _noticeLabel.text=[NSString stringWithFormat:@"%@引用您说：%@",threadsNotice.user.userName,threadsNotice.noticeContext];
    }
    NSRange noticeContentRange=[_noticeLabel.text rangeOfString:@"您说："];
    NSMutableAttributedString *noticeAttributedString=[[NSMutableAttributedString alloc]initWithString:_noticeLabel.text];
    [noticeAttributedString addAttribute:NSForegroundColorAttributeName value:LZHThreadsNoticeLightWordsColor range:NSMakeRange(noticeContentRange.length+noticeContentRange.location, noticeAttributedString.length-noticeContentRange.length-noticeContentRange.location)];
    _noticeLabel.attributedText=noticeAttributedString;
}

-(void)layoutSubviews{
    [_postTimeLabel sizeToFit];
    _postTimeLabel.frame=CGRectMake(_viewWidth-_postTimeLabel.frame.size.width-LZHThreadsNoticeDistanceBetweenViews, LZHThreadsNoticeDistanceBetweenViews, _postTimeLabel.frame.size.width, _postTimeLabel.frame.size.height);
    
    CGSize opticalTitleLableSize=[_titleLabel sizeThatFits:CGSizeMake(_viewWidth-3*LZHThreadsNoticeDistanceBetweenViews-_postTimeLabel.frame.size.width, 9999)];
    _titleLabel.frame=CGRectMake(LZHThreadsNoticeDistanceBetweenViews, LZHThreadsNoticeDistanceBetweenViews, opticalTitleLableSize.width, opticalTitleLableSize.height);
    
    CGSize opticalMyReplyLableSize=[_myReplyLabel sizeThatFits:CGSizeMake(_viewWidth-2*LZHThreadsNoticeDistanceBetweenViews, 9999)];
    _myReplyLabel.frame=CGRectMake(LZHThreadsNoticeDistanceBetweenViews, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+LZHThreadsNoticeDistanceBetweenViews,opticalMyReplyLableSize.width, opticalMyReplyLableSize.height);
    
    
    CGSize opticalNoticeLabelSize=[_noticeLabel sizeThatFits:CGSizeMake(_viewWidth-2*LZHThreadsNoticeDistanceBetweenViews, 9999)];
    _noticeLabel.frame=CGRectMake(LZHThreadsNoticeDistanceBetweenViews, _myReplyLabel.frame.origin.y+_myReplyLabel.frame.size.height+LZHThreadsNoticeDistanceBetweenViews, opticalNoticeLabelSize.width, opticalNoticeLabelSize.height);
    
    _seperatorLabel.backgroundColor=LZHThreadsNoticeSeperatorColor;
    _seperatorLabel.frame=CGRectMake(LZHThreadsNoticeDistanceBetweenViews, _noticeLabel.frame.origin.y+_noticeLabel.frame.size.height+LZHThreadsNoticeDistanceBetweenViews, _viewWidth-LZHThreadsNoticeDistanceBetweenViews, 1.0f);
}

+(CGFloat)cellHeightForThreadsNotice:(LZHThreadNotice *)threadsNotice{
    CGFloat viewWidth=[[UIScreen mainScreen]bounds].size.width;
    
    UILabel *noticeLabel=[[UILabel alloc]init];
    noticeLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
    if (threadsNotice.noticeType==LZHTHreadsNoticeTypeReply) {
        noticeLabel.text=[NSString stringWithFormat:@"%@答复您说：%@",threadsNotice.user.userName,threadsNotice.noticeContext];
    }else{
        noticeLabel.text=[NSString stringWithFormat:@"%@引用您说：%@",threadsNotice.user.userName,threadsNotice.noticeContext];
    }
    noticeLabel.numberOfLines=0;
    noticeLabel.lineBreakMode=NSLineBreakByCharWrapping;
    noticeLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
    CGSize opticalNoticContextLableSize=[noticeLabel sizeThatFits:CGSizeMake(viewWidth-2*LZHThreadsNoticeDistanceBetweenViews, 9999)];
    
    
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.text=threadsNotice.title;
    titleLabel.numberOfLines=0;
    titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
    titleLabel.font=[UIFont boldSystemFontOfSize:LZHThreadsNoticeBigFontSize];
    UILabel *postTimeLabel=[[UILabel alloc]init];
    postTimeLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
    postTimeLabel.text=threadsNotice.postTime;
    [postTimeLabel sizeToFit];
    
    CGSize opticalTitleLableSize=[titleLabel sizeThatFits:CGSizeMake(viewWidth-postTimeLabel.frame.size.width-3*LZHThreadsNoticeDistanceBetweenViews, 9999)];
    
    UILabel *myReplyContextLabel=[[UILabel alloc]init];
    myReplyContextLabel.text=[NSString stringWithFormat:@"您的帖子：%@",threadsNotice.myReplyContext];
    myReplyContextLabel.numberOfLines=0;
    myReplyContextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    myReplyContextLabel.font=[UIFont systemFontOfSize:LZHThreadsNoticeSmallFontSize];
    
    CGSize opticalMyReplyContextLabelSize=[myReplyContextLabel sizeThatFits:CGSizeMake(viewWidth-2*LZHThreadsNoticeDistanceBetweenViews, 9999)];
    
    return 4*LZHThreadsNoticeDistanceBetweenViews+opticalTitleLableSize.height+opticalNoticContextLableSize.height+opticalMyReplyContextLabelSize.height+1.0f;
}

@end
