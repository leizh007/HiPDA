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
#import "LZNotice.h"
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


NSString *const LZHThreadDataSourceChange=@"LZHThreadDataSourceChange";
static const NSInteger kDiscoveryFid=2;
static const NSInteger kBuyAndSellFid=6;
static const NSInteger kGeekTalkFid=7;
static const NSInteger kMachineFid=57;
static const NSInteger kEINKFid=59;
NSString *const LZHDiscoveryFidString=@"LZHDiscoveryFidString";
NSString *const LZHBuyAndSellFidString=@"LZHBuyAndSellFidString";
NSString *const LZHGeekTalkFidString=@"LZHGeekTalkFidString";
NSString *const LZHMachineFidString=@"LZHMachineFidString";
NSString *const LZHEINKFidString=@"LZHEINKFidString";

@interface LZHThreadViewController ()

@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *threads;
@property (assign, nonatomic) NSInteger fid;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSDictionary *threadFidDictionary;

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
    [button addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    _barButton=[[BBBadgeBarButtonItem alloc]initWithCustomUIButton:button];
    _barButton.badgeOriginX=12;
    _barButton.badgeOriginY=-11;
    self.navigationItem.leftBarButtonItem=_barButton;
    
    //注册KVO
    LZNotice *notice=[LZNotice shareNotice];
    [notice addObserver:self forKeyPath:@"sumPrompt" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

    //注册notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:LZHThreadDataSourceChange object:nil];
    
    //设置tableView
    self.tableView=[[UITableView alloc]initWithFrame:self.view.frame];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    
    //初始化数据
    self.threads=[[NSMutableArray alloc]init];
    _fid=kDiscoveryFid;
    _page=1;
    _threadFidDictionary=@{LZHDiscoveryFidString:[NSNumber numberWithInteger:kDiscoveryFid],
                           LZHBuyAndSellFidString:[NSNumber numberWithInteger:kBuyAndSellFid],
                           LZHGeekTalkFidString:[NSNumber numberWithInteger:kGeekTalkFid],
                           LZHMachineFidString:[NSNumber numberWithInteger:kMachineFid],
                           LZHEINKFidString:[NSNumber numberWithInteger:kEINKFid]};
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=YES;
    revealViewController.tapGestureRecognizer.enabled=YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=NO;
    revealViewController.tapGestureRecognizer.enabled=NO;
}

#pragma mark - Notification

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:LZHLOGGINSUCCESSNOTIFICATION]) {
        [self pullDownToRefresh];
        [self pullUpToLoadMore];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sumPrompt"]) {
        _barButton.badgeValue=[NSString stringWithFormat:@"%ld",[[LZNotice shareNotice] sumPrompt]];
    }
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.threads.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    LZHThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[LZHThreadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    [cell configureThread:self.threads[indexPath.row]];
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]],
                          [MGSwipeButton buttonWithTitle:@"黑名单" backgroundColor:[UIColor colorWithRed:0.781 green:0.778 blue:0.801 alpha:1]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    
    cell.delegate=self;
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
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableView + 下拉刷新 动画图片
- (void)pullDownToRefresh
{
    // 添加动画图片的下拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    [self.tableView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd", i]];
        [idleImages addObject:image];
    }
    [self.tableView.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self.tableView.gifHeader setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
    // 在这个例子中，即将刷新 和 正在刷新 用的是一样的动画图片
    
    // 马上进入刷新状态
    [self.tableView.gifHeader beginRefreshing];
    
    // 此时self.tableView.header == self.tableView.gifHeader
}

#pragma mark - UITableView + 上拉刷新 动画图片
- (void)pullUpToLoadMore
{
    // 添加动画图片的上拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.tableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd", i]];
        [refreshingImages addObject:image];
    }
    self.tableView.gifFooter.refreshingImages = refreshingImages;
    // 此时self.tableView.footer == self.tableView.gifFooter
}

#pragma mark - 数据处理相关

- (void)loadNewData
{
    _page=1;
    [LZHNetworkFetcher loadForumFid:_fid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            _threads=[array mutableCopy];
        }
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
    }];
}


- (void)loadMoreData
{
    ++_page;
    [LZHNetworkFetcher loadForumFid:_fid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            [_threads addObjectsFromArray:array];
        }
        [self.tableView reloadData];
        [self.tableView.footer endRefreshing];
    }];
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    //0为delete,1为blacklist
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    if (index==1) {
        [[LZHBlackList sharedBlackList] addUIDToBlackList:((LZHThread *)_threads[indexPath.row]).user.uid];
    }
    [_threads removeObjectAtIndex:indexPath.row];
    
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
    return YES;
}

@end
