//
//  LZHThreadViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHThreadViewController.h"
#import "UIBarButtonItem+ImageItem.h"
#import "SWRevealViewController.h"
#import "LZHNotice.h"
#import "MTLog.h"
#import "BBBadgeBarButtonItem.h"
#import "MJRefresh.h"
#import "LZHNetworkFetcher.h"
#import "LZHThreadTableViewCell.h"
#import "LZHUser.h"
#import "LZHAccount.h"
#import "LZHThread.h"
#import "LZHShowMessage.h"
#import "LZHReadList.h"
#import "MGSwipeButton.h"
#import "LZHBlackList.h"
#import "LZHPostViewController.h"
#import "SDImageCache.h"
#import "LZHReplyViewController.h"

NSString *const LZHThreadDataSourceChange=@"LZHThreadDataSourceChange";
const NSInteger LZHDiscoveryFid=2;
const NSInteger LZHBuyAndSellFid=6;
const NSInteger LZHGeekTalkFid=7;
const NSInteger LZHMachineFid=57;
const NSInteger LZHEINKFid=59;
NSString *const LZHDiscoveryFidString=@"LZHDiscoveryFidString";
NSString *const LZHBuyAndSellFidString=@"LZHBuyAndSellFidString";
NSString *const LZHGeekTalkFidString=@"LZHGeekTalkFidString";
NSString *const LZHMachineFidString=@"LZHMachineFidString";
NSString *const LZHEINKFidString=@"LZHEINKFidString";
static const CGFloat kButtonSize=22.0f;

@interface LZHThreadViewController ()

@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *threads;
@property (assign, nonatomic) NSInteger fid;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSDictionary *threadFidDictionary;
@property (strong, nonatomic) UIImageView *replyImageView;
@property (strong, nonatomic) UIButton *replyButton;
@property (strong, nonatomic) UIButton *refreshButton;
@property (strong, nonatomic) UIImageView *refreshImageView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation LZHThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置revealViewController的手势操作
    SWRevealViewController *revealViewController=[self revealViewController];
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    
    //设置leftBarButtonItem
    UIButton *button=[[UIButton alloc]init];
    [button setBackgroundImage:[UIImage imageNamed:@"RevealToggleImage"] forState:UIControlStateNormal];
    [button sizeToFit];
    //NSLog(@"%lf",button.frame.size.width);
    [button addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    _barButton=[[BBBadgeBarButtonItem alloc]initWithCustomUIButton:button];
    _barButton.badgeOriginX=12;
    _barButton.badgeOriginY=-11;
    _barButton.badgeMinSize=5.0f;
    self.navigationItem.leftBarButtonItem=_barButton;
    
    [self setNavigationBarRightItemsIsRefreshing:NO];
    
    //注册KVO
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice addObserver:self forKeyPath:@"sumPrompt" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

    //注册notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:LZHThreadDataSourceChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:LZHLOGGINSUCCESSNOTIFICATION object:nil];
    
    //设置tableView
    self.tableView=[[UITableView alloc]initWithFrame:self.view.frame];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    
    //初始化数据
    self.threads=[[NSMutableArray alloc]init];
    _fid=LZHDiscoveryFid;
    _page=1;
    _threadFidDictionary=@{LZHDiscoveryFidString:[NSNumber numberWithInteger:LZHDiscoveryFid],
                           LZHBuyAndSellFidString:[NSNumber numberWithInteger:LZHBuyAndSellFid],
                           LZHGeekTalkFidString:[NSNumber numberWithInteger:LZHGeekTalkFid],
                           LZHMachineFidString:[NSNumber numberWithInteger:LZHMachineFid],
                           LZHEINKFidString:[NSNumber numberWithInteger:LZHEINKFid]};
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=YES;
    revealViewController.tapGestureRecognizer.enabled=YES;
    
    [self setNavigationTitle];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=NO;
    revealViewController.tapGestureRecognizer.enabled=NO;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    //[imageCache clearDisk];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice removeObserver:self forKeyPath:@"sumPrompt"];
}

-(void)setNavigationTitle{
    NSString *navigationTitle;
    switch (_fid) {
        case LZHDiscoveryFid:
            navigationTitle=@"Discovery";
            break;
        case LZHBuyAndSellFid:
            navigationTitle=@"Buy & Sell";
            break;
        case LZHGeekTalkFid:
            navigationTitle=@"GeekTalk";
            break;
        case LZHMachineFid:
            navigationTitle=@"疑似机器人";
            break;
        case LZHEINKFid:
            navigationTitle=@"E-INK";
            break;
    }
    self.navigationItem.title=navigationTitle;
}

-(void)setNavigationBarRightItemsIsRefreshing:(BOOL)refresh{
    if (_replyButton==nil) {
        _replyButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _replyImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"replyBlack"] highlightedImage:[UIImage imageNamed:@"replyBlackHighlighted"]];
        _replyImageView.frame=CGRectMake(0, 0, kButtonSize, kButtonSize);
        _replyButton.frame=CGRectMake(0, 0, kButtonSize*1.5, kButtonSize);
        _replyImageView.contentMode=UIViewContentModeScaleToFill;
        [_replyButton addSubview:_replyImageView];
        [_replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (_refreshButton==nil) {
        _refreshButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _refreshImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"refresh"] highlightedImage:[UIImage imageNamed:@"refreshHighlighed"]];
        _refreshImageView.frame=CGRectMake(0, 0, kButtonSize, kButtonSize);
        _refreshButton.frame=CGRectMake(0, 0, kButtonSize, kButtonSize);
        _refreshImageView.contentMode=UIViewContentModeScaleToFill;
        [_refreshButton addSubview:_refreshImageView];
        [_refreshButton addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (_activityIndicatorView==nil) {
        _activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, kButtonSize, kButtonSize)];
        _activityIndicatorView.color=[UIColor blackColor];
        [_activityIndicatorView startAnimating];
    }
    if (refresh) {
        UIBarButtonItem *replyButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_replyButton];
        UIBarButtonItem *activityButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_activityIndicatorView];
        self.navigationItem.rightBarButtonItems=@[activityButtonItem,replyButtonItem];
    }else{
        UIBarButtonItem *replyButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_replyButton];
        UIBarButtonItem *refreshButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_refreshButton];
        self.navigationItem.rightBarButtonItems=@[refreshButtonItem,replyButtonItem];
    }
}

#pragma mark - Button Pressed

-(void)replyButtonPressed:(UIButton *)button{
    _replyImageView.highlighted=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _replyImageView.highlighted=NO;
    });
    
    LZHReplyViewController *replyViewController=[[LZHReplyViewController alloc]init];
    replyViewController.fid=[NSString stringWithFormat:@"%ld",_fid];
    replyViewController.page=1;
    replyViewController.pid=@"";
    replyViewController.replyType=LZHReplyTypeNewTopic;
    replyViewController.tid=@"";
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:replyViewController];
    [self.revealViewController presentViewController:navigationController animated:YES completion:nil];
    
}

-(void)refreshButtonPressed:(UIButton *)button{
    [self setNavigationBarRightItemsIsRefreshing:YES];
    [_tableView.header beginRefreshing];
}

#pragma mark - Notification

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:LZHLOGGINSUCCESSNOTIFICATION]) {
        [self pullDownToRefresh];
        [self pullUpToLoadMore];
    }else if([notification.name isEqualToString:LZHThreadDataSourceChange]){
        NSDictionary *userInfo=notification.userInfo;
        _fid=[userInfo[@"LZHThreadFid"] integerValue];
        _page=1;
        [self setNavigationTitle];
        [_tableView.header beginRefreshing];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sumPrompt"]) {
        _barButton.badgeValue=[[NSString stringWithFormat:@"%ld",[[LZHNotice sharedNotice] sumPrompt]] copy];
    }
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.threads.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"LZHThreadTableViewCell";
    LZHThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[LZHThreadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    [cell configureThread:self.threads[indexPath.row]];
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]],
                          [MGSwipeButton buttonWithTitle:@" 黑名单 " backgroundColor:[UIColor colorWithRed:0.781 green:0.778 blue:0.801 alpha:1]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    
    cell.delegate=self;
    
    cell.selectionStyle=UITableViewCellEditingStyleNone;
    return cell;
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LZHThreadTableViewCell cellHeightForThread:_threads[indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LZHThread *thread=_threads[indexPath.row];
    thread.hasRead=YES;
    [[LZHReadList sharedReadList] addTid:thread.tid];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_tableView reloadData];
    LZHPostViewController *postViewController=[[LZHPostViewController alloc]init];
    postViewController.tid=thread.tid;
    postViewController.page=1;
    postViewController.pid=@"";
    postViewController.isRedirect=NO;
    postViewController.URLString=@"";
    [self.navigationController pushViewController:postViewController animated:YES];
}

#pragma mark - UITableView + 下拉刷新 动画图片
- (void)pullDownToRefresh
{
    __weak typeof(self) weakSelf = self;
    
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    [self.tableView.header beginRefreshing];
    
}

#pragma mark - UITableView + 上拉刷新 动画图片
- (void)pullUpToLoadMore
{
    __weak typeof(self) weakSelf = self;
    
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.tableView.footer.hidden=YES;
}

#pragma mark - 数据处理相关

- (void)loadNewData
{
    _page=1;
    __weak typeof(self) weakSelf=self;
    [LZHThread loadForumFid:_fid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            weakSelf.threads=[array mutableCopy];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.header endRefreshing];
        [weakSelf setNavigationBarRightItemsIsRefreshing:NO];
        
        weakSelf.tableView.footer.hidden=NO;
    }];
}


- (void)loadMoreData
{
    ++_page;
    __weak typeof(self) weakSelf=self;
    [LZHThread loadForumFid:_fid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            [weakSelf.threads addObjectsFromArray:array];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.footer endRefreshing];
    }];
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    //0为delete,1为blacklist
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    if (index==1) {
        [[LZHBlackList sharedBlackList] addUserNameToBlackList:((LZHThread *)_threads[indexPath.row]).user.userName];
        [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:[NSString stringWithFormat:@"您已将用户：%@ 残忍加入小黑屋！",[((LZHThread *)_threads[indexPath.row]).user userName]]];
    }
    [_threads removeObjectAtIndex:indexPath.row];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
    return YES;
}

@end
