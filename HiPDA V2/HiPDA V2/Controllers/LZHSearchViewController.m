//
//  LZHSearchViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/12.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHSearchViewController.h"
#import "MJRefresh.h"
#import "LZHSearchResult.h"
#import "SVProgressHUD.h"
#import "NSString+LZHHIPDA.h"
#import "LZHUser.h"
#import "LZHSearchResultTableViewCell.h"

static const CGFloat kDistanceBetweenViews=8.0f;

#define LZHSearchViewWidth [[UIScreen mainScreen]bounds].size.width

@interface LZHSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResultArray;
@property (assign, nonatomic) NSInteger totalPageNumber;
@property (assign, nonatomic) NSInteger currentPageNumber;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation LZHSearchViewController{
    CGFloat tableViewPositionY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=@"搜索";
    self.view.backgroundColor=[UIColor whiteColor];
    _searchResultArray=[[NSMutableArray alloc]init];
    _totalPageNumber=1;
    _currentPageNumber=1;
    
    _activityIndicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    _activityIndicator.color=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1];
    [_activityIndicator stopAnimating];
    [_activityIndicator hidesWhenStopped];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_activityIndicator];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    
    
    if (_user==nil) {
        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, LZHSearchViewWidth, 41)];
        _searchBar.delegate=self;
        _searchBar.showsCancelButton=YES;
        [self.view addSubview:_searchBar];
        
        _segmentedControl=[[UISegmentedControl alloc]initWithItems:@[@"标题",@"全文"]];
        _segmentedControl.frame=CGRectMake(kDistanceBetweenViews*2, _searchBar.frame.origin.y+_searchBar.frame.size.height+kDistanceBetweenViews/2, LZHSearchViewWidth-4*kDistanceBetweenViews, 30);
        _segmentedControl.selectedSegmentIndex=0;
        [_segmentedControl setEnabled:NO forSegmentAtIndex:1];
        [self.view addSubview:_segmentedControl];
        
        tableViewPositionY=_segmentedControl.frame.origin.y+_segmentedControl.frame.size.height+kDistanceBetweenViews/2;
    }else{
        tableViewPositionY=0;
    }
    _tableView=[[UITableView alloc]init];
    _tableView.frame=CGRectMake(0, tableViewPositionY, LZHSearchViewWidth, [[UIScreen mainScreen]bounds].size.height-tableViewPositionY);
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.tableFooterView=[[UIView alloc]init];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [_tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData:)];
    _tableView.footer.hidden=YES;
    [self.view addSubview:_tableView];
    
    if (_user!=nil) {
        [self loadNewData];
    }
}

#pragma mark - Setter & Getter

-(void)setTotalPageNumber:(NSInteger)totalPageNumber{
    if (totalPageNumber>_totalPageNumber) {
        _totalPageNumber=totalPageNumber;
    }
}

-(void)setCurrentPageNumber:(NSInteger)currentPageNumber{
    _currentPageNumber=currentPageNumber;
    if (_currentPageNumber==_totalPageNumber) {
        [_tableView.footer noticeNoMoreData];
    }else{
        [_tableView.footer resetNoMoreData];
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_activityIndicator startAnimating];
    _currentPageNumber=1;
    NSString *URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/search.php?srchtype=title&srchtxt=%@&searchsubmit=true&st=on&srchuname=&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=%ld",[searchBar.text urlEncode],_currentPageNumber];
    [LZHSearchResult getSearchResultInURLString:URLString completionHanlder:^(NSArray *array, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchResultArray=[array mutableCopy];
            [_searchResultArray removeObjectAtIndex:0];
            
            self.totalPageNumber=[array[0] integerValue];
            self.currentPageNumber=1;
            self.tableView.footer.hidden=NO;
            [_tableView reloadData];
            [_activityIndicator stopAnimating];
        });
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=@""; 
    [searchBar resignFirstResponder];
}

#pragma mark -  数据相关

-(void)loadNewData{
    [_activityIndicator startAnimating];
    NSString *userName=_user.userName;
    _currentPageNumber=1;
    NSString *URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/search.php?srchtype=title&srchtxt=&searchsubmit=true&st=on&srchuname=%@&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=%ld",[userName urlEncode],_currentPageNumber];
    [LZHSearchResult getSearchResultInURLString:URLString completionHanlder:^(NSArray *array, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchResultArray=[array mutableCopy];
            [_searchResultArray removeObjectAtIndex:0];
            
            self.totalPageNumber=[array[0] integerValue];
            self.currentPageNumber=1;
            [_tableView reloadData];
            [_activityIndicator stopAnimating];
            self.tableView.footer.hidden=NO;
        });
    }];
}

-(void)loadMoreData:(id)sender{
    NSString *URLString;
    if (_user!=nil) {
        URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/search.php?srchtype=title&srchtxt=&searchsubmit=true&st=on&srchuname=%@&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=%ld",[_user.userName urlEncode],_currentPageNumber+1];
    }else{
        URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/search.php?srchtype=title&srchtxt=%@&searchsubmit=true&st=on&srchuname=&srchfilter=all&srchfrom=0&before=&orderby=lastpost&ascdesc=desc&page=%ld",[_searchBar.text urlEncode],_currentPageNumber+1];
    }
    [LZHSearchResult getSearchResultInURLString:URLString completionHanlder:^(NSArray *array, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *mutableArray=[array mutableCopy];
            [mutableArray removeObjectAtIndex:0];
            [_searchResultArray addObjectsFromArray:mutableArray];
            
            self.totalPageNumber=[array[0] integerValue];
            self.currentPageNumber=self.currentPageNumber+1;
            [_tableView reloadData];
            [_tableView.footer endRefreshing];
        });
    }];
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchResultArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reusableCellWithIdentifier=@"LZHSearchResultTableViewCellReusableCellWithIdentifier";
    LZHSearchResultTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell==nil) {
        cell=[[LZHSearchResultTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    [cell configureSearchResult:_searchResultArray[indexPath.row]];
    
    return cell;
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [LZHSearchResultTableViewCell cellHeightForSearchResult:_searchResultArray[indexPath.row]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
