//
//  LZHMemCPViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMemberContorlPanelViewController.h"
#import "MTLog.h"
#import "LZHNotice.h"
#import "LZHThreadViewController.h"
#import "LZHAccount.h"
#import "LZHNetworkFetcher.h"
#import "CustomBadge.h"
#import "LZHNotice.h"
#import "LZHThreadViewController.h"
#import "LZHPersonalMessageViewController.h"
#import "LZHMyThreadViewController.h"
#import "LZHSearchViewController.h"
#import "LZHSettingsViewController.h"

const CGFloat LZHRearViewRevealWidth = 182.0f;
const CGFloat kDistanceBetweenViews  = 8.0f;
const CGFloat kAvatarImageViewSize   = 45.0f;
const CGFloat kButtonWidth           = 50.0f;
const CGFloat kButtonHeight          = 45.5f;
const CGFloat kImageViewWidth        = 25.0f;

#define kBackgroundColor [UIColor colorWithRed:0.134 green:0.162 blue:0.188 alpha:1]
#define kHighlightedBackgroundColor ([UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1])
#define kDefaultFontColor ([UIColor colorWithRed:0.581 green:0.6 blue:0.617 alpha:1])
#define kHighlightedFontColor ([UIColor colorWithRed:0.999 green:1 blue:1 alpha:1])
#define kSeperatorLineColor ([UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1])

@interface LZHMemberContorlPanelViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UILabel      *titleLable;
@property (strong, nonatomic) UILabel      *seperatorLabelBetweenTitleAndAvatar;
@property (strong, nonatomic) UIImageView  *avatarImageView;
@property (strong, nonatomic) UILabel      *userNameLabel;
@property (strong, nonatomic) UIButton     *noticeButton;
@property (weak,   nonatomic) UIImageView  *noticeImageView;
@property (strong,   nonatomic) CustomBadge  *noticeBadge;
@property (strong, nonatomic) UIButton     *threadButton;
@property (weak,   nonatomic) UIImageView  *threadImageView;
@property (strong,   nonatomic) CustomBadge  *threadBadge;
@property (strong, nonatomic) UIButton     *searchButton;
@property (weak,   nonatomic) UIImageView  *searchImageView;
@property (strong, nonatomic) UILabel      *seperatorLabelUponTableView;
@property (strong, nonatomic) UIButton     *settingsButton;
@property (weak,   nonatomic) UIImageView  *settingsImageView;
@property (strong, nonatomic) UIButton     *dayNightModeButton;
@property (weak,   nonatomic) UIImageView  *dayNightModeImageView;
@property (strong, nonatomic) UITableView  *tableView;
@property (strong, nonatomic) NSArray      *fidArray;
@property (strong, nonatomic) NSDictionary *fidDictionary;
@property (strong, nonatomic) UINavigationController *presentNavigationController;

@end

@implementation LZHMemberContorlPanelViewController{
    BOOL isDayMode;
    NSInteger selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=kBackgroundColor;
    
    //初始化参数
    _fidArray=@[@"Discovery",@"Buy & Sell",@"E-INK",@"Geek Talks",@"疑似机器人"];
    _fidDictionary=@{@"Discovery":[NSNumber numberWithInteger:LZHDiscoveryFid],
                     @"Buy & Sell":[NSNumber numberWithInteger:LZHBuyAndSellFid],
                     @"E-INK":[NSNumber numberWithInteger:LZHEINKFid],
                     @"Geek Talks":[NSNumber numberWithInteger:LZHGeekTalkFid],
                     @"疑似机器人":[NSNumber numberWithInteger:LZHMachineFid]};
    selectedIndex=0;
    
    //标题
    _titleLable=[[UILabel alloc]init];
    _titleLable.text=@"个人中心";
    _titleLable.font=[UIFont boldSystemFontOfSize:18.0f];
    _titleLable.textColor=kDefaultFontColor;
    _titleLable.textAlignment=NSTextAlignmentCenter;
    _titleLable.frame=CGRectMake(0, 20.0f, LZHRearViewRevealWidth, 44);
    _titleLable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_titleLable];
    
    //分割线
    _seperatorLabelBetweenTitleAndAvatar=[[UILabel alloc]initWithFrame:CGRectMake(0, 64, LZHRearViewRevealWidth, 1.0f)];
    _seperatorLabelBetweenTitleAndAvatar.backgroundColor=kSeperatorLineColor;
    [self.view addSubview:_seperatorLabelBetweenTitleAndAvatar];

    //头像
    LZHAccount *account=[LZHAccount sharedAccount];
    NSDictionary *accountInfo=[account account];
    _avatarImageView=[[UIImageView alloc]initWithFrame:CGRectMake(kDistanceBetweenViews, _seperatorLabelBetweenTitleAndAvatar.frame.origin.y+_seperatorLabelBetweenTitleAndAvatar.frame.size.height+kDistanceBetweenViews, kAvatarImageViewSize, kAvatarImageViewSize)];
    if ([accountInfo[LZHACCOUNTUSERAVATAR] isEqual:[NSNull null]]) {
        _avatarImageView.image=[UIImage imageNamed:@"avatar"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:LZHUSERINFOLOADCOMPLETENOTIFICATION object:nil];
    }else{
        _avatarImageView.image=accountInfo[LZHACCOUNTUSERAVATAR];
    }
    _avatarImageView.layer.cornerRadius=5.0f;
    _avatarImageView.layer.borderColor=[[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1] CGColor];
    _avatarImageView.layer.borderWidth=1.0f;
    _avatarImageView.clipsToBounds=YES;
    [self.view addSubview:_avatarImageView];
    
    //用户名
    _userNameLabel=[[UILabel alloc]init];
    _userNameLabel.text=accountInfo[LZHACCOUNTUSERNAME];
    _userNameLabel.textColor=kDefaultFontColor;
    _userNameLabel.numberOfLines=0;
    _userNameLabel.lineBreakMode=NSLineBreakByCharWrapping;
    CGSize maxUserNameLabelSize=CGSizeMake(LZHRearViewRevealWidth-kAvatarImageViewSize-kDistanceBetweenViews*3, 9999);
    CGSize optimicalSize=[_userNameLabel sizeThatFits:maxUserNameLabelSize];
    _userNameLabel.frame=CGRectMake(2*kDistanceBetweenViews+kAvatarImageViewSize, _avatarImageView.frame.origin.y+_avatarImageView.frame.size.height/2-optimicalSize.height/2, optimicalSize.width, optimicalSize.height);
    [self.view addSubview:_userNameLabel];
    
    LZHNotice *notice=[LZHNotice sharedNotice];
    //消息
    _noticeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *noticeImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"notice"] highlightedImage:[UIImage imageNamed:@"notice-Highlighted"]];
    noticeImageView.frame=CGRectMake(kImageViewWidth/2, kImageViewWidth/2, kImageViewWidth, kImageViewWidth);
    noticeImageView.contentMode=UIViewContentModeScaleAspectFit;
    _noticeImageView=noticeImageView;
    _noticeButton.frame=CGRectMake(kDistanceBetweenViews, _avatarImageView.frame.origin.y+_avatarImageView.frame.size.height+kDistanceBetweenViews, kButtonWidth, kButtonHeight);
    [_noticeButton addSubview:noticeImageView];
    CustomBadge *noticeBadge=[CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%ld",notice.sumPromptPm] withScale:0.8];
    if (notice.sumPromptPm==0) {
        noticeBadge.hidden=YES;
    }
    _noticeBadge=noticeBadge;
    noticeBadge.frame=CGRectMake(noticeImageView.frame.size.width+noticeImageView.frame.origin.x-noticeBadge.frame.size.width/2, noticeImageView.frame.origin.y-noticeBadge.frame.size.height/2, noticeBadge.frame.size.width, noticeBadge.frame.size.height);
    [_noticeButton addSubview:noticeBadge];
    [_noticeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_noticeButton];
    
    //帖子
    _threadButton=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *threadImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Document"] highlightedImage:[UIImage imageNamed:@"Document-Highlighted"]];
    _threadImageView=threadImageView;
    threadImageView.frame=CGRectMake(kImageViewWidth/2, kImageViewWidth/2, kImageViewWidth, kImageViewWidth);
    threadImageView.contentMode=UIViewContentModeScaleAspectFit;
    _threadButton.frame=CGRectMake(_noticeButton.frame.origin.x+_noticeButton.frame.size.width+kDistanceBetweenViews, _noticeButton.frame.origin.y, kButtonWidth, kButtonHeight);
    [_threadButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_threadButton addSubview:threadImageView];
    CustomBadge *threadBadge=[CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%ld",notice.promptThreads] withScale:0.8];
    _threadBadge=threadBadge;
    if (notice.promptThreads==0) {
        threadBadge.hidden=YES;
    }
    threadBadge.frame=CGRectMake(threadImageView.frame.size.width+threadImageView.frame.origin.x-threadBadge.frame.size.width/2, threadImageView.frame.origin.y-threadBadge.frame.size.height/2, threadBadge.frame.size.width, threadBadge.frame.size.height);
    [_threadButton addSubview:threadBadge];
    [self.view addSubview:_threadButton];
    
    //搜索
    _searchButton=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *searchImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Find"] highlightedImage:[UIImage imageNamed:@"Find-Highlighted"]];
    _searchImageView=searchImageView;
    searchImageView.frame=CGRectMake(kImageViewWidth/2, kImageViewWidth/2, kImageViewWidth, kImageViewWidth);
    searchImageView.contentMode=UIViewContentModeScaleAspectFit;
    _searchButton.frame=CGRectMake(_threadButton.frame.origin.x+_threadButton.frame.size.width+kDistanceBetweenViews, _noticeButton.frame.origin.y, kButtonWidth, kButtonHeight);
    [_searchButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_searchButton addSubview:searchImageView];
    [self.view addSubview:_searchButton];
    
    //seperator
    _seperatorLabelUponTableView=[[UILabel alloc]initWithFrame:CGRectMake(0, _noticeButton.frame.origin.y+_noticeButton.frame.size.height, LZHRearViewRevealWidth, 1.0f)];
    _seperatorLabelUponTableView.backgroundColor=kHighlightedBackgroundColor;
    [self.view addSubview:_seperatorLabelUponTableView];
    
    //settings
    _settingsButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _settingsButton.frame=CGRectMake(kDistanceBetweenViews, [[UIScreen mainScreen]bounds].size.height-kDistanceBetweenViews-kButtonWidth, kButtonWidth, kButtonWidth);
    [_settingsButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *settingsImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Settings"] highlightedImage:[UIImage imageNamed:@"Settings-Highlighted"]];
    _settingsImageView=settingsImageView;
    settingsImageView.frame=CGRectMake(kButtonWidth/2-kImageViewWidth/2, kButtonWidth/2-kImageViewWidth/2, kImageViewWidth, kImageViewWidth);
    settingsImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_settingsButton addSubview:settingsImageView];
    [self.view addSubview:_settingsButton];
    
    //mode
    isDayMode=YES;
    _dayNightModeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _dayNightModeButton.frame=CGRectMake(LZHRearViewRevealWidth-kDistanceBetweenViews-kButtonWidth, _settingsButton.frame.origin.y, kButtonWidth, kButtonWidth);
    [_dayNightModeButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *dayNightModeImageView=[[UIImageView alloc]init];
    _dayNightModeImageView=dayNightModeImageView;
    if (isDayMode) {
        dayNightModeImageView.image=[UIImage imageNamed:@"night"];
    }else{
        dayNightModeImageView.image=[UIImage imageNamed:@"day"];
    }
    dayNightModeImageView.frame=CGRectMake(kButtonWidth/2-kImageViewWidth/2, kButtonWidth/2-kImageViewWidth/2, kImageViewWidth, kImageViewWidth);
    dayNightModeImageView.contentMode=UIViewContentModeScaleAspectFit;
    [_dayNightModeButton addSubview:dayNightModeImageView];
    [self.view addSubview:_dayNightModeButton];
    _dayNightModeButton.hidden=YES;
    
    //注册KVO
    [notice addObserver:self forKeyPath:@"sumPromptPm" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [notice addObserver:self forKeyPath:@"promptThreads" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    //tableView
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, _seperatorLabelUponTableView.frame.origin.y+_seperatorLabelUponTableView.frame.size.height, LZHRearViewRevealWidth, _dayNightModeButton.frame.origin.y-_seperatorLabelUponTableView.frame.origin.y-_seperatorLabelUponTableView.frame.size.height)];
    _tableView.backgroundColor=kBackgroundColor;
    _tableView.separatorColor=kHighlightedBackgroundColor;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.tableFooterView=[[UIView alloc]init];
    [self.view addSubview:_tableView];
}



#pragma  mark - Button Pressed

-(void)buttonPressed:(id)sender{
    UIButton *button=(UIButton *)sender;
    if (button==_dayNightModeButton) {
        isDayMode=!isDayMode;
        if (isDayMode) {
            _dayNightModeImageView.image=[UIImage imageNamed:@"night"];
        }else{
            _dayNightModeImageView.image=[UIImage imageNamed:@"day"];
        }
        return;
    }
    [self resetImageViewsHighlighted];
    UIViewController *navigationRootViewController;
    if (button==_noticeButton) {
        _noticeImageView.highlighted=YES;
        navigationRootViewController=[[LZHPersonalMessageViewController alloc]init];
    }else if(button==_threadButton){
        _threadImageView.highlighted=YES;
        navigationRootViewController=[[LZHMyThreadViewController alloc]init];
    }else if(button == _searchButton){
        _searchImageView.highlighted=YES;
        navigationRootViewController=[[LZHSearchViewController alloc]init];
    }else if(button==_settingsButton){
        _settingsImageView.highlighted=YES;
        navigationRootViewController=[[LZHSettingsViewController alloc]init];
    }
    _presentNavigationController=[[UINavigationController alloc]initWithRootViewController:navigationRootViewController];
    UIButton *leftButton=[[UIButton alloc]init];
    [leftButton setTitle:@"完成" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1] forState:UIControlStateNormal];
    [leftButton sizeToFit];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(navigationBarLeftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(navigationBarLeftButtonPressed:)];
    navigationRootViewController.navigationItem.leftBarButtonItem=leftButtonItem;
    navigationRootViewController.view.backgroundColor=[UIColor whiteColor];
    [self presentViewController:_presentNavigationController animated:YES completion:nil];
}

-(void)resetImageViewsHighlighted{
    _noticeImageView.highlighted=NO;
    _threadImageView.highlighted=NO;
    _searchImageView.highlighted=NO;
    _settingsImageView.highlighted=NO;
}

-(void)navigationBarLeftButtonPressed:(id)sender{
    [_presentNavigationController dismissViewControllerAnimated:YES completion:nil];
    [self resetImageViewsHighlighted];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    LZHNotice *notice=[LZHNotice sharedNotice];
    if ([keyPath isEqualToString:@"sumPromptPm"]) {
        if (notice.sumPromptPm==0) {
            _noticeBadge.hidden=YES;
        }else{
            _noticeBadge.badgeText=[NSString stringWithFormat:@"%ld",notice.sumPromptPm];
            _noticeBadge.hidden=NO;
        }
    }else if([keyPath isEqualToString:@"promptThreads"]){
        if (notice.promptThreads==0) {
            _threadBadge.hidden=YES;
        }else{
            _threadBadge.badgeText=[NSString stringWithFormat:@"%ld",notice.promptThreads];
            _threadBadge.hidden=NO;
        }
    }
}

#pragma  mark - Notification

-(void)hanldNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:LZHUSERINFOLOADCOMPLETENOTIFICATION]) {
        _avatarImageView.image=((NSDictionary *)[LZHAccount sharedAccount].account)[LZHACCOUNTUSERAVATAR];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

#pragma  mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fidArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellReusedIdentifier=@"cellReusedIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellReusedIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReusedIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=_fidArray[indexPath.row];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.row==selectedIndex) {
        cell.backgroundColor=[UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1];
        cell.textLabel.textColor=[UIColor colorWithRed:0.999 green:1 blue:1 alpha:1];
    }else{
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor=[UIColor colorWithRed:0.581 green:0.6 blue:0.617 alpha:1];
    }
    return cell;
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self resetImageViewsHighlighted];
    selectedIndex=indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:LZHThreadDataSourceChange
                                                        object:nil
                                                      userInfo:@{@"LZHThreadFid":_fidDictionary[_fidArray[indexPath.row]]}];
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - SWRevealViewControllerDelegate
/**
 *  当rearview出现的时候禁止frontview的触控
 *
 *  @param revealController revealController
 *  @param position         当position为FrontViewPositionRight时才禁止
 */
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        UIView *lockingView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView setTag:1000];
        [revealController.frontViewController.view addSubview:lockingView];
    }
    else
        [[revealController.frontViewController.view viewWithTag:1000] removeFromSuperview];
}


@end
