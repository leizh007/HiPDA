//
//  LZViewThreadDetailViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/30.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZViewThreadDetailViewController.h"
#import "SWRevealViewController.h"
#import "LZNetworkHelper.h"
#import "LZThreadDetail.h"
#import "LZThreadListTableViewCell.h"
#import "NSString+extension.h"
#import "LZPopUpWebViewController.h"
#import "LZShowMessagesHelper.h"
#import "RTLabel.h"
#import "UIBarButtonItem+ImageItem.h"
#import "ActionSheetStringPicker.h"
#import "LZNetworkHelper.h"
#import "LZSendPostViewController.h"
#import "LZUser.h"
#import "LZPost.h"

#define SMALLDOTSBUTTONWIDTH 40
#define INSETBETWEENVIEWELEMENTS 8
#define LOADMOREBUTTONTAGINTABLEFOOTERVIEW 2
#define ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW 3
#define PULLTOREFRESH 1
#define LOADMORE 2

@interface LZViewThreadDetailViewController ()

@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *threadList;
@property (strong, nonatomic) UIRefreshControl *refreshControll;
@property (assign, nonatomic) NSInteger fullPageNumber;

@end

@implementation LZViewThreadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor greenColor];
    self.page=1;
    self.threadList=[[NSMutableArray alloc]init];
    self.fullPageNumber=0;
    //设置tableview
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=nil;
    self.tableView.tableHeaderView=[self getUITableHeaderView];
    //初始化刷新控件
    self.refreshControll=[[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControll];
    [self.refreshControll addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    [self loadPostListTid:self.tid page:self.page isForced:NO loadType:PULLTOREFRESH];
}



-(void)viewDidAppear:(BOOL)animated{
    /**
     *  移除SWRevealViewController的手势操作
     */
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=NO;
    revealViewController.tapGestureRecognizer.enabled=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.threadList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LZThreadListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LZThreadListTableViewCell"];
    if (cell==nil) {
        cell=[[LZThreadListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LZThreadListTableViewCell"];
    }
    [cell configure:self.threadList[indexPath.row] parent:self];
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LZThreadListTableViewCell *cell=[[LZThreadListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LZThreadListTableViewCell"];
    [cell configure:self.threadList[indexPath.row] parent:self];
    CGSize s = [cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    return s.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LZSendPostViewController *sendPostViewController=[[LZSendPostViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController: sendPostViewController];
    sendPostViewController.navTitle=[NSString stringWithFormat:@"回复 ＃%ld %@",((LZThreadDetail *)self.threadList[indexPath.row]).postnum+1,((LZThreadDetail *)self.threadList[indexPath.row]).user.userName];
    sendPostViewController.postType=POSTTYPEREPLY;
    sendPostViewController.fid=self.fid;
    LZPost *post=[[LZPost alloc]init];
    sendPostViewController.tid=self.tid;
    post.pid=((LZThreadDetail *)self.threadList[indexPath.row]).pid;
    post.floorNumber=((LZThreadDetail *)self.threadList[indexPath.row]).postnum+1;
    post.user=((LZThreadDetail *)self.threadList[indexPath.row]).user;
    sendPostViewController.post=post;
    nav.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    [self.revealViewController presentViewController:nav animated:YES completion:nil];

}

#pragma mark - RTLabelDelegate

-(void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url{
//    NSLog(@"%@",[url absoluteString]);
    LZPopUpWebViewController *popUpWebViewController=[[LZPopUpWebViewController alloc]init];
    popUpWebViewController.url=url;
    popUpWebViewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:popUpWebViewController];
    [self presentViewController:nav animated:YES completion:^{
    }];
}

#pragma mark - Refresh

-(void)loadPostListTid:(NSString *)tid page:(NSInteger) page isForced:(BOOL)isForced loadType:(int)type{
    if (!isForced) {
        [self.refreshControll beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -2*self.refreshControll.frame.size.height) animated:NO];
    }
    [[LZNetworkHelper sharedLZNetworkHelper] loadPostListTid:tid page:page isNeedPageFullNumber:YES success:^(NSDictionary *postThreadInfo) {
        NSArray *threadDetailList=[postThreadInfo objectForKey:@"threadlist"];
        if ([[postThreadInfo objectForKey:@"page"] integerValue]>self.fullPageNumber) {
            self.fullPageNumber=[[postThreadInfo objectForKey:@"page"] integerValue];
        }
        if (type==PULLTOREFRESH) {
            self.threadList=[threadDetailList mutableCopy];
        }else{
            [self.threadList addObjectsFromArray:threadDetailList];
        }
        self.tableView.tableFooterView=[self getUITableFooterView];
        self.tableView.tableHeaderView=[self getUITableHeaderView];
        [self.refreshControll endRefreshing];
        [self.tableView reloadData];
        [self setRightBarButtonItems];
    } failure:^(NSError *error) {
        [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
    }];
}

- (void) refreshTable:(id)sender
{
    /*
     
     Code to actually refresh goes here.
     
     */
    if (self.page!=1) {
        self.page=self.page-1;
    }
    [self loadPostListTid:self.tid page:self.page isForced:YES loadType:PULLTOREFRESH];
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
    UIButton *button=(UIButton *)[self.tableView.tableFooterView viewWithTag:LOADMOREBUTTONTAGINTABLEFOOTERVIEW];
    [button setTitle:@"正在加载..." forState:UIControlStateNormal];
    [(UIActivityIndicatorView *)[self.tableView.tableFooterView viewWithTag:ACTIVITYINDICATORFLAGINTABLEFOOTERVIEW] startAnimating];
    [self loadPostListTid:self.tid page:self.page isForced:YES loadType:LOADMORE];
}

#pragma mark - UITableFooterView
-(id)getUITableFooterView{
    if ([self.threadList count]==0) {
        return [[UIView alloc]init];
    }
    if (self.fullPageNumber>self.page) {
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
    }else{
        UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50)];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(INSETBETWEENVIEWELEMENTS*2, INSETBETWEENVIEWELEMENTS, footerView.frame.size.width-4*INSETBETWEENVIEWELEMENTS, footerView.frame.size.height-2*INSETBETWEENVIEWELEMENTS)];
        label.text=@"已经是最后一页了";
        label.textColor=[UIColor colorWithRed:0.628 green:0.625 blue:0.646 alpha:1];
        label.textAlignment=NSTextAlignmentCenter;
        [footerView addSubview:label];
        return footerView;
    }
}

#pragma mark - UITableHeaderView
-(id)getUITableHeaderView{
    UIView *headerView=[[UIView alloc]init];
    if (self.page!=1) {
        return headerView;
    }
    RTLabel *rtlabel=[[RTLabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width-2*INSETBETWEENVIEWELEMENTS, 99999)];
    [rtlabel setText:self.threadTitle];
    rtlabel.textColor=[UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1];
    rtlabel.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    CGSize optSize=[rtlabel optimumSize];
    rtlabel.frame=CGRectMake([[UIScreen mainScreen]bounds].size.width/2-optSize.width/2,INSETBETWEENVIEWELEMENTS*2, optSize.width, optSize.height);
    
    headerView.frame=CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, optSize.height+4*INSETBETWEENVIEWELEMENTS);
    [headerView addSubview:rtlabel];
    
    return headerView;
}

#pragma mark - NavigationItem RightBarButtonItems

-(void)setRightBarButtonItems{
    UIBarButtonItem *replyButtonItem=[UIBarButtonItem barItemWithImage:[UIImage imageNamed:@"reply"] target:self action:@selector(replyButtonPressed:)];
    UIButton *pageButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
    [pageButton setTitle:[NSString stringWithFormat:@"%ld/%ld",self.page,self.fullPageNumber] forState:UIControlStateNormal];
    [pageButton setTitleColor:[UIColor colorWithRed:0.403 green:0.403 blue:0.403 alpha:1] forState:UIControlStateNormal];
    [pageButton addTarget:self action:@selector(pageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pageButtonItem=[[UIBarButtonItem alloc]initWithCustomView:pageButton];
    self.navigationItem.rightBarButtonItems=@[replyButtonItem,pageButtonItem];
}

-(void)replyButtonPressed:(id)sender{
    LZSendPostViewController *sendPostViewController=[[LZSendPostViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController: sendPostViewController];
    sendPostViewController.navTitle=@"回复";
    sendPostViewController.postType=POSTTYPENEWPOST;
    sendPostViewController.fid=self.fid;
    LZPost *post=[[LZPost alloc]init];
    sendPostViewController.tid=self.tid;
    post.pid=((LZThreadDetail *)self.threadList[0]).pid;
    post.floorNumber=1;
    post.user=self.user;
    sendPostViewController.post=post;
    nav.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    [self.revealViewController presentViewController:nav animated:YES completion:^{
        
    }];

}

-(void)pageButtonPressed:(id)sender{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.1];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:1];
                     }];
    if (self.fullPageNumber==1) {
        return;
    }
    NSMutableArray *numArray=[[NSMutableArray alloc]init];
    for (NSInteger i=1; i<=self.fullPageNumber; ++i) {
        [numArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"请选择页数"
                                            rows:numArray
                                initialSelection:self.page-1
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.page=selectedIndex+1;
                                           [self loadPostListTid:self.tid page:self.page isForced:NO loadType:PULLTOREFRESH];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:self.view
     ];
}

@end
