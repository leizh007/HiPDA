//
//  LZThreadListTableViewCell.m
//  HiPDA
//
//  Created by leizh007 on 15/4/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZThreadListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RTLabel.h"

#define INSETBETWEENVIEWELEMENTS 8
#define AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT 40
#define SMLLLABELFONTSIZE 15
#define BIGLABELFONTSIZE 18
#define HEADANDFOOTLABELHEIGHT 1
#define DEFAULTLABELTEXTCOLOR ([UIColor colorWithRed:1 green:0.622 blue:0 alpha:1])
#define MAINCONTEXTTEXTCOLOR ([UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1])

@interface LZThreadListTableViewCell()

@property (strong, nonatomic) NSMutableArray *viewArray;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *numLabel;
@property (strong, nonatomic) UILabel *headLabel;
@property (strong, nonatomic) UILabel *footLabel;

@end

@implementation LZThreadListTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.viewArray=[[NSMutableArray alloc]init];
        
        //设置头像图
        self.avatarImageView=[[UIImageView alloc]initWithFrame:CGRectMake(INSETBETWEENVIEWELEMENTS, INSETBETWEENVIEWELEMENTS+1, AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT, AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT)];
        self.avatarImageView.layer.cornerRadius=15.0f;
        [self.avatarImageView.layer setMasksToBounds:YES];
        self.avatarImageView.layer.borderWidth=1.0f;
        self.avatarImageView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        [self.contentView addSubview:self.avatarImageView];
        
        self.userNameLabel=[[UILabel alloc]init];
        self.timeLabel=[[UILabel alloc]init];
        self.numLabel=[[UILabel alloc]init];
        
        self.userNameLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:SMLLLABELFONTSIZE];
        self.userNameLabel.textColor=DEFAULTLABELTEXTCOLOR;
        self.numLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:SMLLLABELFONTSIZE];
        self.numLabel.textColor=DEFAULTLABELTEXTCOLOR;
        self.timeLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:SMLLLABELFONTSIZE];
        self.timeLabel.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
        
        [self.contentView addSubview:self.userNameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.numLabel];
        
        
        //设置头部分割线
        self.headLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, HEADANDFOOTLABELHEIGHT)];
        [self.contentView addSubview:self.headLabel];
        self.headLabel.backgroundColor=[UIColor colorWithRed:0.899 green:0.899 blue:0.899 alpha:1];
        
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

-(void)configure:(LZThreadDetail *)threadDetail{
    [self.avatarImageView sd_setImageWithURL:threadDetail.user.avatarImageUrl];
    self.userNameLabel.text=threadDetail.user.userName;
    self.timeLabel.text=threadDetail.time;
    if (threadDetail.postnum==0) {
        self.numLabel.text=@"楼主";
    }else{
        self.numLabel.text=[NSString stringWithFormat:@"%ld#",threadDetail.postnum+1];
    }
    [self.userNameLabel sizeToFit];
    [self.timeLabel sizeToFit];
    [self.numLabel sizeToFit];
    
    
    /**
     *  add constrains
     */
    //headlabel
    NSLayoutConstraint *headlabelTop=[NSLayoutConstraint constraintWithItem:self.headLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:headlabelTop];
    NSLayoutConstraint *headlabelX=[NSLayoutConstraint constraintWithItem:self.headLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:headlabelX];
    //avatart
    NSLayoutConstraint *avatarConstrainTop=[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:avatarConstrainTop];
    NSLayoutConstraint *avatarConstrainLeft=[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:avatarConstrainLeft];
    //userName
    //对view用constrain必需把translatesAutoresizingMaskIntoConstraints置为NO
    self.userNameLabel.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint *userNameConstrainLeft=[NSLayoutConstraint constraintWithItem:self.userNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:userNameConstrainLeft];
    NSLayoutConstraint *userNameConstrainCenY=[NSLayoutConstraint constraintWithItem:self.userNameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.contentView addConstraint:userNameConstrainCenY];
    
    //numlabel
    self.numLabel.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint *numberX=[NSLayoutConstraint constraintWithItem:self.numLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:numberX];
    NSLayoutConstraint *numberY=[NSLayoutConstraint constraintWithItem:self.numLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:numberY];
    
    //timelabel;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints=NO;
    NSLayoutConstraint *timelableX=[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.numLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:timelableX];
    NSLayoutConstraint *timelabelY=[NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.contentView addConstraint:timelabelY];
    
    UIView *topView=self.avatarImageView;
    for (NSDictionary *dic in threadDetail.contextArray) {
        if ([dic objectForKey:THREADLISTDETAILSTRING]!=nil) {
            RTLabel *rtlabel=[[RTLabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width-AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT-3*INSETBETWEENVIEWELEMENTS, 99999)];
            [rtlabel setText:[dic objectForKey:THREADLISTDETAILSTRING]];
            rtlabel.textColor=MAINCONTEXTTEXTCOLOR;
            rtlabel.font=[UIFont fontWithName:@"HelveticaNeue" size:16];
            CGSize optSize=[rtlabel optimumSize];
            rtlabel.frame=CGRectMake(0, 0, optSize.width, optSize.height);
            [self.viewArray addObject:rtlabel];
            rtlabel.translatesAutoresizingMaskIntoConstraints=NO;
            [self.contentView addSubview:rtlabel];
            
            [rtlabel removeConstraints:rtlabel.constraints];
            NSLayoutConstraint *rtlabelX=[NSLayoutConstraint constraintWithItem:rtlabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
            [self.contentView addConstraint:rtlabelX];
            NSLayoutConstraint *rtlabelY=[NSLayoutConstraint constraintWithItem:rtlabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
            [self.contentView addConstraint:rtlabelY];
            NSLayoutConstraint *rtlabelW=[NSLayoutConstraint constraintWithItem:rtlabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeWidth multiplier:0.0 constant:optSize.width];
            [self.contentView addConstraint:rtlabelW];
            NSLayoutConstraint *rtlabelH=[NSLayoutConstraint constraintWithItem:rtlabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeHeight multiplier:0.0 constant:optSize.height];
            [self.contentView addConstraint:rtlabelH];
            
            topView=rtlabel;
        }else if([dic objectForKey:THREADLISTDETAILIMAGE]!=nil){
            UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0.1, 0.1)];
            imgView.backgroundColor=[UIColor whiteColor];
            CGFloat maxWidth=[[UIScreen mainScreen] bounds].size.width-3*INSETBETWEENVIEWELEMENTS-AVATARIMAGEVIEWSIZEWIDTHANDHEIGHT;
            imgView.translatesAutoresizingMaskIntoConstraints=NO;
            [self.contentView addSubview:imgView];
            [self.viewArray addObject:imgView];
            
            NSLayoutConstraint *imgX=[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
            [self.contentView addConstraint:imgX];
            NSLayoutConstraint *imgY=[NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:INSETBETWEENVIEWELEMENTS];
            [self.contentView addConstraint:imgY];
            
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(UIImageView *) weakImgView=imgView;
            
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:THREADLISTDETAILIMAGE]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                CGFloat width=image.size.width>maxWidth?maxWidth:image.size.width;
                NSLayoutConstraint *imgW1=[NSLayoutConstraint constraintWithItem:weakImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0.0 constant:width];
                [weakSelf.contentView addConstraint:imgW1];
                NSLayoutConstraint *imgH1=[NSLayoutConstraint constraintWithItem:weakImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0.0 constant:width*image.size.height/(image.size.width+0.00001)];
                
                [weakSelf.contentView addConstraint:imgH1];
                
                [weakSelf needsUpdateConstraints];
                [weakSelf layoutIfNeeded];
                [weakSelf layoutSubviews];
                
                id view = [weakSelf superview];
                
                while (view && [view isKindOfClass:[UITableView class]] == NO) {
                    view = [view superview];
                }
                if (view && [view isKindOfClass:[UITableView class]]) {
                    UITableView *tableView = (UITableView *)view;
                    NSIndexPath *indexPath = [tableView indexPathForCell:weakSelf];
                    if (indexPath!=nil) {
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
                    }
                }
                
            }];
        
            topView=imgView;
            
        }
    }
    NSLayoutConstraint *bottom=[NSLayoutConstraint constraintWithItem:topView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-INSETBETWEENVIEWELEMENTS];
    [self.contentView addConstraint:bottom];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    self.avatarImageView.image=nil;
    [self.contentView removeConstraints:self.contentView.constraints];
    for (UIView *view in self.viewArray) {
        if ([view isKindOfClass:[UIImageView class]]) {
            ((UIImageView*)view).image=nil;
        }
        [view removeFromSuperview];
    }
    [self.viewArray removeAllObjects];
}

@end
