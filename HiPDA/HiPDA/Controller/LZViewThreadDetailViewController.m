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

@interface LZViewThreadDetailViewController ()

@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) UITableView *tableView;
@property (strong ,nonatomic) NSArray *threadList;

@end

@implementation LZViewThreadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor greenColor];
    self.page=1;

    
    //设置tableview
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView=nil;
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:THREADLISTDETAILIMAGELOADEDDONENOTIFICATION object:nil];
//    self.navigationItem.title=self.threadTitle;
//    NSLog(@"%@",self.tid);
    [[LZNetworkHelper sharedLZNetworkHelper] loadPostListTid:self.tid page:self.page isNeedPageFullNumber:YES success:^(NSDictionary *postThreadInfo) {
        NSArray *threadDetailList=[postThreadInfo objectForKey:@"threadlist"];
        self.threadList=threadDetailList;
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
}

-(void)refresh:(id)sender{
    [self.tableView reloadData];
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
    [cell configure:self.threadList[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LZThreadListTableViewCell *cell=[[LZThreadListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LZThreadListTableViewCell"];
    [cell configure:self.threadList[indexPath.row]];
    CGSize s = [cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    return s.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
