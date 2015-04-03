//
//  LZMainThreadViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZMainThreadViewController.h"
#import "SWRevealViewController.h"
#import "UIBarButtonItem+ImageItem.h"
#import "BBBadgeBarButtonItem.h"
#import "LZNetworkHelper.h"
#import "LZThread.h"
#import "LZUser.h"
#import "LZCache.h"
#import "LZThreadTableViewCell.h"
#import "LZShowMessagesHelper.h"
#import "LZPersistenceDataManager.h"
#import "LZViewThreadDetailViewController.h"
#import "RTLabel.h"
#import "LZSendPostViewController.h"

#define SMALLDOTSBUTTONWIDTH 40
#define INSETBETWEENVIEWELEMENTS 8
#define LOADMOREBUTTONTAGINTABLEFOOTERVIEW 2
#define ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW 3

@interface LZMainThreadViewController()

@property (assign, nonatomic) NSInteger fid;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray *threads;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *smallDotsButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *tableFooterView;


@end

@implementation LZMainThreadViewController

-(void)viewDidLoad{
    SWRevealViewController *revealViewController=[self revealViewController];
    [revealViewController panGestureRecognizer];
    [revealViewController tapGestureRecognizer];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //初始化变量
    self.fid=DISCOVERYSECTIONFID;
    self.page=1;
    self.threads=[[NSMutableArray alloc]init];
    self.tableFooterView=[self getUITableFooterView];
    
    //设置tableview
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=nil;
    
    //初始化刷新控件
    self.refreshControl=[[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    //设置小圆点按键
    self.smallDotsButton=[[UIButton alloc]init];
    self.smallDotsButton.backgroundColor=[UIColor colorWithRed:0.314 green:0.601 blue:1 alpha:1];
    [self.smallDotsButton setAlpha:0.7];
    [self.smallDotsButton addTarget:self action:@selector(smallDotsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.smallDotsButton];
    [self.view bringSubviewToFront:self.smallDotsButton];
    self.smallDotsButton.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width-120, [[UIScreen mainScreen]bounds].size.height-120, SMALLDOTSBUTTONWIDTH, SMALLDOTSBUTTONWIDTH);
    self.smallDotsButton.layer.cornerRadius=20.0;
    self.smallDotsButton.hidden=YES;
    
    //设置navigationBar外观
    self.navigationController.navigationBar.translucent=YES;
    self.navigationController.navigationBar.barTintColor=[UIColor whiteColor];
    self.navigationItem.title=@"Discovery";
    UIImage *leftBarButtonItemImage=[UIImage imageNamed:@"leftBarButtonItemImage"];
    UIButton *button=[[UIButton alloc] init];
    [button setImage:leftBarButtonItemImage forState:UIControlStateNormal];
    button.bounds=CGRectMake(0, 0, leftBarButtonItemImage.size.width, leftBarButtonItemImage.size.height);
    [button addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    BBBadgeBarButtonItem *barButton=[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:button];
    barButton.badgeValue=@"0";
    self.navigationItem.leftBarButtonItem=barButton;
    UIBarButtonItem *buttonItem=[UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"reply"] target:self action:@selector(replyButtonPressed:)];
    self.navigationItem.rightBarButtonItem=buttonItem;
    
    
}

-(void)viewDidAppear:(BOOL)animated{

    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=YES;
    revealViewController.tapGestureRecognizer.enabled=YES;
}


-(void)loadForumFid:(NSInteger)fid page:(NSInteger)page forced:(BOOL)isFoced{
    if (!isFoced) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -2*self.refreshControl.frame.size.height) animated:NO];
    }
    if (fid!=self.fid) {
        switch (fid) {
            case DISCOVERYSECTIONFID:
                self.navigationItem.title=@"Discovery";
                break;
            case BUYANDSELLSECTIONFID:
                self.navigationItem.title=@"Buy & Sell";
                break;
            case EINKSECTIONFID:
                self.navigationItem.title=@"E-INK";
                break;
            case GEEKTALKSSECTIONFID:
                self.navigationItem.title=@"Geek Talks";
                break;
            case MACHINESECTIONFID:
                self.navigationItem.title=@"疑似机器人";
                break;
            default:
                break;
        }
        NSMutableArray *threadsCache=[[[LZCache globalCache]loadForumCacheFid:fid page:page] mutableCopy];
        if (threadsCache!=nil) {
            self.threads=threadsCache;
            [self.tableView reloadData];
        }
    }
    self.fid=fid;
    self.page=page;
    [[LZNetworkHelper sharedLZNetworkHelper] loadForumFid:self.fid page:self.page success:^(NSArray *threads) {
        if (self.page==1) {
            self.threads=[threads mutableCopy];
        }else{
            [self.threads addObjectsFromArray:threads];
        }
        [self.refreshControl endRefreshing];
        if (!self.tableView.tableFooterView) {
            self.tableView.tableFooterView=self.tableFooterView;
        }
        [(UIButton *)[self.tableFooterView viewWithTag:LOADMOREBUTTONTAGINTABLEFOOTERVIEW] setTitle:@"点击加载下一页" forState:UIControlStateNormal];
        [(UIActivityIndicatorView *)[self.tableFooterView viewWithTag:ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW] stopAnimating];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
    }];
    
}

#pragma mark - NSNotifications
/**
 *  接收到通知的时候调用
 *
 *  @param notification 帖子正在加载和帖子正在解析
 */
-(void)getNotifications:(NSNotification *)notification{
    if ([notification.name isEqualToString:LOGINCOMPLETENOTIFICATION]) {
        NSMutableArray *threadsCache=[[[LZCache globalCache]loadForumCacheFid:self.fid page:self.page] mutableCopy];
        if (threadsCache!=nil) {
            self.threads=threadsCache;
            [self.tableView reloadData];
        }
        [self loadForumFid:self.fid page:self.page forced:NO];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.threads count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LZThreadTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LZThreadTableViewCell"];
    if (cell==nil) {
        cell=[[LZThreadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LZThreadTableViewCell"];
    }
    [cell configure:self.threads[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LZThreadTableViewCell getCellHeight:self.threads[indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ((LZThread *)self.threads[indexPath.row]).hasRead=YES;
    [[LZPersistenceDataManager sharedPersistenceDataManager] addThreadTidToHasRead:((LZThread *)self.threads[indexPath.row]).tid];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    LZViewThreadDetailViewController *viewThreadDetailViewController=[[LZViewThreadDetailViewController alloc]init];
    viewThreadDetailViewController.tid=((LZThread *)self.threads[indexPath.row]).tid;
    viewThreadDetailViewController.fid=self.fid;
    viewThreadDetailViewController.user=((LZThread *)self.threads[indexPath.row]).user;
    viewThreadDetailViewController.threadTitle=((LZThread *)self.threads[indexPath.row]).title;
    [self.navigationController pushViewController:viewThreadDetailViewController animated:YES];
}

#pragma mark - smallDotsButton action

-(void)smallDotsButtonPressed:(id)sender{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.1];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:0.7];
                     }];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    self.page=1;
    [self loadForumFid:self.fid page:self.page forced:NO];
}

#pragma mark - Refresh and load more methods

- (void) refreshTable:(id)sender
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.page=1;
    [self loadForumFid:self.fid page:self.page forced:YES];
}

- (void) loadMoreDataToTable:(id)sender
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.page=self.page+1;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.1];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:0.7];
                     }];
    UIButton *button=(UIButton *)[self.tableFooterView viewWithTag:LOADMOREBUTTONTAGINTABLEFOOTERVIEW];
    [button setTitle:@"正在加载..." forState:UIControlStateNormal];
    [(UIActivityIndicatorView *)[self.tableFooterView viewWithTag:ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW] startAnimating];
    [self loadForumFid:self.fid page:self.page forced:YES];
}

#pragma mark - UITableFooterView
-(id)getUITableFooterView{
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50)];
//    footerView.backgroundColor=[UIColor blueColor];
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(INSETBETWEENVIEWELEMENTS*2, INSETBETWEENVIEWELEMENTS, footerView.frame.size.width-4*INSETBETWEENVIEWELEMENTS, footerView.frame.size.height-2*INSETBETWEENVIEWELEMENTS)];
    [button setTitle:@"点击加载下一页" forState:UIControlStateNormal];
    button.layer.cornerRadius=5.0f;
    button.layer.borderColor=[[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1]CGColor];
    button.layer.borderWidth=1.0;
    [button setTitleColor:[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1] forState:UIControlStateNormal ];
    [button addTarget:self action:@selector(loadMoreDataToTable:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    button.tag=LOADMOREBUTTONTAGINTABLEFOOTERVIEW;
    
    UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(6*INSETBETWEENVIEWELEMENTS, 12.5, 25, 25)];
    [footerView addSubview:activityIndicator];
    activityIndicator.tag=ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW;
    activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    return footerView;
}

#pragma mark - replyButton

-(void)replyButtonPressed:(id)sender{
    LZSendPostViewController *sendPostViewController=[[LZSendPostViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController: sendPostViewController];
    NSString *title=[[NSString alloc]init];
    switch (self.fid) {
        case DISCOVERYSECTIONFID:
            title=@"Discovery发表新帖";
            break;
        case BUYANDSELLSECTIONFID:
            title=@"Buy & Sell发表新帖";
            break;
        case EINKSECTIONFID:
            title=@"E-INK发表新帖";
            break;
        case GEEKTALKSSECTIONFID:
            title=@"Geek Talks发表新帖";
            break;
        case MACHINESECTIONFID:
            title=@"疑似机器人发表新帖";
            break;
        default:
            break;
    }
    sendPostViewController.navTitle=title;
    sendPostViewController.postType=POSTTYPENEWTHREAD;
    sendPostViewController.fid=self.fid;
    nav.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    [self.revealViewController presentViewController:nav animated:YES completion:^{
        
    }];
}


@end
