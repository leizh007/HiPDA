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


static const CGFloat MJDuration = 2.0;

@interface LZHThreadViewController ()

@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *threads;

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
    _barButton.badgeValue=@"8";
    _barButton.badgeOriginX=12;
    _barButton.badgeOriginY=-11;
    self.navigationItem.leftBarButtonItem=_barButton;
    
    //注册KVO
    LZNotice *notice=[LZNotice shareNotice];
    [notice addObserver:self forKeyPath:@"sumPrompt" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

    
    //设置tableView
    self.tableView=[[UITableView alloc]initWithFrame:self.view.frame];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self pullDownToRefresh];
    [self pullUpToLoadMore];
    
    //初始化数据
    self.threads=[[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated{
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=YES;
    revealViewController.tapGestureRecognizer.enabled=YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=NO;
    revealViewController.tapGestureRecognizer.enabled=NO;
}

#pragma mark - Notification

-(void)handleNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:LZHLOGGINSUCCESSNOTIFICATION]) {
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"sumPrompt"]) {
        _barButton.badgeValue=[NSString stringWithFormat:@"%ld",[[LZNotice shareNotice] sumPrompt]];
        NSLog(@"%ld",[[LZNotice shareNotice] sumPrompt]);
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
    
    return cell;
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LZHThreadTableViewCell *cell=[[LZHThreadTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [cell configureThread:self.threads[indexPath.row]];
    CGSize optSize=[cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    return optSize.height;
}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}

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
//    [self.tableView.gifHeader beginRefreshing];
    
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
    self.tableView.footer.hidden=YES;
    // 此时self.tableView.footer == self.tableView.gifFooter
}

#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        LZHAccount *account=[LZHAccount sharedAccount];
        LZHUser *user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:[[account account]objectForKey:LZHACCOUNTUSERUID],
                                                           LZHUSERUSERNAME:[[account account]objectForKey:LZHACCOUNTUSERNAME]}];
        LZHThread *thread=[[LZHThread alloc]initWithUser:user replyCount:10 totalCount:20 postTime:@"2015-4-1" title:[NSString stringWithFormat:@"%d",i] tid:@"199" hasAttach:YES hasImage:NO];
        [self.threads addObject:thread];
    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tableView.footer.hidden==YES) {
            self.tableView.footer.hidden=NO;
        }
        // 刷新表格
        [self.tableView reloadData];
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.header endRefreshing];
    });
}

#pragma mark 上拉加载更多数据
- (void)loadMoreData
{
//    // 1.添加假数据
//    for (int i = 0; i<5; i++) {
////        [self.data addObject:@"20"];
//    }
//    
//    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 刷新表格
//        [self.tableView reloadData];
//        
//        // 拿到当前的上拉刷新控件，结束刷新状态
//        [self.tableView.footer endRefreshing];
//    });
}

@end
