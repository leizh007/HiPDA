//
//  LZHMyThreadViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/12.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMyThreadViewController.h"
#import "LZHAccount.h"
#import "LZHNotice.h"
#import "MJRefresh.h"
#import "HMSegmentedControl.h"
#import "UIImage+LZHHIPDA.h"
#import "LZHThreadNotice.h"
#import "LZHShowMessage.h"
#import "LZHThreadsNoticeTableViewCell.h"
#import "LZHMyThread.h"
#import "LZHMyThreadsTableViewCell.h"
#import "LZHMyPost.h"
#import "LZHMyPostsTableViewCell.h"
#import "LZHMyFavorite.h"
#import "LZHMyFavoritesTableViewCell.h"
#import "LZHHTTPRequestOperationManager.h"
#import "NSString+LZHHIPDA.h"
#import "LZHPostViewController.h"


#define kBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]

@interface LZHMyThreadViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray     *tableViewArray;
@property (strong, nonatomic) NSMutableArray     *myThreadsDataArray;
@property (strong, nonatomic) UIScrollView       *scrollView;
@property (strong, nonatomic) UIImage            *myReplyImage;
@property (strong, nonatomic) UIImage            *myFavoritesImage;
@property (assign, nonatomic) NSInteger          selectedSegmentedIndex;
@property (assign, nonatomic) CGFloat            viewWidth;
@property (assign, nonatomic) CGFloat            viewHeight;

@end

@implementation LZHMyThreadViewController{
    NSInteger totalPages[4];
    NSInteger curPage[4];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"我的帖子";
    
    for (int i=0; i<4; ++i) {
        totalPages[i]=1;
        curPage[i]=1;
    }
    
    _selectedSegmentedIndex=0;
    _viewWidth=[[UIScreen mainScreen]bounds].size.width;
    
    _myReplyImage=[UIImage segmentedImageWithTitle:@"我的回复" badgeValue:0];
    _myFavoritesImage=[UIImage segmentedImageWithTitle:@"我的收藏" badgeValue:0];
    
    [self updateSegmentedControl];
    
    _myThreadsDataArray=[NSMutableArray arrayWithArray:@[[NSNull null],[NSNull null],[NSNull null],[NSNull null]]];
    _tableViewArray=[[NSMutableArray alloc]init];
    
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, _segmentedControl.frame.origin.y+_segmentedControl.frame.size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-_segmentedControl.frame.origin.y-_segmentedControl.frame.size.height)];
    _scrollView.backgroundColor=[UIColor grayColor];
    _scrollView.backgroundColor = kBackgroundColor;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_viewWidth * 4, 200);
    _scrollView.delegate = self;
    _viewHeight=_scrollView.frame.size.height;
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, _viewWidth, _viewHeight) animated:NO];
    [self.view addSubview:self.scrollView];
    
    _tableViewArray=[[NSMutableArray alloc]init];
    __weak typeof(self) weakSelf=self;
    for (int i=0; i<4; ++i) {
        UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(_viewWidth*i, 0, _viewWidth, _viewHeight)];
        tableView.tag=i+1;
        tableView.delegate=self;
        tableView.dataSource=self;
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [tableView addLegendHeaderWithRefreshingBlock:^{
            [weakSelf loadNewDataWithTag:i+1];
        }];
        [tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf loadMoreDataWithTag:i+1];
        }];
        tableView.footer.hidden=YES;
        [_scrollView addSubview:tableView];
        if (i==0) {
            [tableView.header beginRefreshing];
        }
        [_tableViewArray addObject:tableView];
    }
    
    //注册KVO
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice addObserver:self forKeyPath:@"promptThreads" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [notice addObserver:self forKeyPath:@"myThreads" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

}

-(void)dealloc{
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice removeObserver:self forKeyPath:@"promptThreads"];
    [notice removeObserver:self forKeyPath:@"myThreads"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"promptThreads"]||[keyPath isEqualToString:@"myThreads"]) {
        [self updateSegmentedControl];
    }
}

#pragma mark - page number

-(void)setTotalPagesPosition:(NSInteger)position number:(NSInteger)number{
    if (totalPages[position]<number) {
        totalPages[position]=number;
    }
}

-(void)setCurPagesPosition:(NSInteger)position number:(NSInteger)number{
    UITableView *tableView=_tableViewArray[position];
    if (totalPages[position]==number) {
        [tableView.footer noticeNoMoreData];
    }else{
        [tableView.footer resetNoMoreData];
    }
    curPage[position]=number;
}

#pragma mark - segment control

-(void)updateSegmentedControl{
    LZHNotice *notice=[LZHNotice sharedNotice];
    UIImage *threadNoticeImage=[UIImage segmentedImageWithTitle:@"帖子消息" badgeValue:notice.promptThreads];
    UIImage *myThreadImage=[UIImage segmentedImageWithTitle:@"我的发表" badgeValue:notice.myThreads];
    if (_segmentedControl!=nil&&_segmentedControl.superview!=nil) {
        [_segmentedControl removeFromSuperview];
    }
    
    _segmentedControl=[[HMSegmentedControl alloc] initWithSectionImages:@[threadNoticeImage,myThreadImage,_myReplyImage,_myFavoritesImage] sectionSelectedImages:@[threadNoticeImage,myThreadImage,_myReplyImage,_myFavoritesImage]];
    
    _segmentedControl.frame=CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, 46);
    _segmentedControl.selectionIndicatorHeight=3.0f;
    _segmentedControl.backgroundColor = [UIColor colorWithRed:0.924 green:0.924 blue:0.924 alpha:1];
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.selectedSegmentIndex=_selectedSegmentedIndex;
    __weak typeof(self) weakSelf = self;
    [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(weakSelf.viewWidth * index, 0, weakSelf.viewWidth, 200) animated:YES];
        weakSelf.selectedSegmentedIndex=index;
        [weakSelf tableViewHeaderEndRefreshing];
        UITableView *tableView=weakSelf.tableViewArray[index];
        [tableView.header beginRefreshing];
    }];
    [self.view addSubview:_segmentedControl];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag!=0) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    if (page!=_segmentedControl.selectedSegmentIndex) {
        [self tableViewHeaderEndRefreshing];
        UITableView *tableView=_tableViewArray[page];
        [tableView.header beginRefreshing];
    }
    [_segmentedControl setSelectedSegmentIndex:page animated:YES];
    _selectedSegmentedIndex=page;
}

#pragma mark - 数据相关

-(void)tableViewHeaderEndRefreshing{
    [_tableViewArray enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL *stop) {
        [tableView.header endRefreshing];
    }];
}

- (void)loadNewDataWithTag:(NSInteger)tag
{
    __weak UITableView *tableView=_tableViewArray[tag-1];
    if (tag==1) {
        [LZHThreadNotice getThreadsNoticeInPage:1 CompletionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.header endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadNewData:array];
                });
            }
        }];
    }else if(tag==2){
        [LZHMyThread getMyThreadsInPage:1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.header endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadNewData:array];
                });
            }
        }];
    }else if(tag==3){
        [LZHMyPost getMyPostsInPage:1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.header endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadNewData:array];
                });
            }
        }];
    }else if(tag==4){
        [LZHMyFavorite getMyFavoritesInPage:1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.header endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadNewData:array];
                });
            }
        }];
    }
}

-(void)prepareDataForTag:(NSInteger) tag afterLoadNewData:(NSArray *)array {
    self.myThreadsDataArray[tag-1]=[array mutableCopy];
    [self.myThreadsDataArray[tag-1] removeObjectAtIndex:0];
    
    UITableView *tableView=self.tableViewArray[tag-1];
    [tableView reloadData];
    [tableView.header endRefreshing];
    
    tableView.footer.hidden=NO;
    [self setTotalPagesPosition:tag-1 number:[array[0] integerValue]];
    [self setCurPagesPosition:tag-1 number:1];
}

- (void)loadMoreDataWithTag:(NSInteger)tag{
    __weak UITableView *tableView=_tableViewArray[tag-1];
    if (tag==1) {
        [LZHThreadNotice getThreadsNoticeInPage:curPage[tag-1]+1 CompletionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.footer endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadMoreData:array];
                });
            }
        }];
    }else if(tag==2){
        [LZHMyThread getMyThreadsInPage:curPage[tag-1]+1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.footer endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadMoreData:array];
                });
            }
        }];
    }else if(tag==3){
        [LZHMyPost getMyPostsInPage:curPage[tag-1]+1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.footer endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadMoreData:array];
                });
            }
        }];
    }else if(tag==4){
        [LZHMyFavorite getMyFavoritesInPage:curPage[tag-1]+1 completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                [tableView.footer endRefreshing];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareDataForTag:tag afterLoadMoreData:array];
                });
            }
        }];
    }
}

-(void)prepareDataForTag:(NSInteger) tag afterLoadMoreData:(NSArray *)array{
    NSMutableArray *mutableArray=[array mutableCopy];
    [mutableArray removeObjectAtIndex:0];
    [self.myThreadsDataArray[tag-1] addObjectsFromArray:mutableArray];
    
    UITableView *tableView=self.tableViewArray[tag-1];
    [tableView reloadData];
    [tableView.footer endRefreshing];
    
    [self setTotalPagesPosition:tag-1 number:[array[0] integerValue]];
    [self setCurPagesPosition:tag-1 number:curPage[tag-1]+1];
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger tag=tableView.tag;
    if ([self.myThreadsDataArray[tag-1] isEqual:[NSNull null]]) {
        return 0;
    }
    NSInteger number=[self.myThreadsDataArray[tag-1] count];
    return number;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag=tableView.tag;
    NSString *reusableCellWithIdentifier=[NSString stringWithFormat:@"reusableCellWithIdentifier+%ld",tag];
    if (tag==1) {
        LZHThreadsNoticeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        if (cell==nil) {
            cell=[[LZHThreadsNoticeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
        }
        [cell configureThreadsNotice:_myThreadsDataArray[tag-1][indexPath.row]];
        return cell;
    }else if(tag==2){
        LZHMyThreadsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        if (cell==nil) {
            cell=[[LZHMyThreadsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
        }
        [cell configureMyThreads:_myThreadsDataArray[tag-1][indexPath.row]];
        return cell;
    }else if(tag==3){
        LZHMyPostsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        if (cell==nil) {
            cell=[[LZHMyPostsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
        }
        [cell configureMyPosts:_myThreadsDataArray[tag-1][indexPath.row]];
        return cell;
    }else{
        LZHMyFavoritesTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
        if (cell==nil) {
            cell=[[LZHMyFavoritesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
        }
        [cell configureMyFavorites:_myThreadsDataArray[tag-1][indexPath.row]];
        return cell;
    }
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag=tableView.tag;
    if (tag==1) {
        return  [LZHThreadsNoticeTableViewCell cellHeightForThreadsNotice:_myThreadsDataArray[tag-1][indexPath.row]];
    }else if(tag==2){
        return [LZHMyThreadsTableViewCell cellHeightForMyThreads:_myThreadsDataArray[tag-1][indexPath.row]];
    }else if(tag==3){
        return [LZHMyPostsTableViewCell cellHeightForMyPosts:_myThreadsDataArray[tag-1][indexPath.row]];
    }else{
        return [LZHMyFavoritesTableViewCell cellHeightForMyFavorites:_myThreadsDataArray[tag-1][indexPath.row]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag=tableView.tag;
    LZHPostViewController *postViewController=[[LZHPostViewController alloc]init];
    if (tag==1) {
        LZHThreadNotice *threadNotice=_myThreadsDataArray[tag-1][indexPath.row];
        NSLog(@"%@",threadNotice.URLString);
        postViewController.isRedirect=YES;
        postViewController.URLString=threadNotice.URLString;
        postViewController.tid=@"";
        postViewController.page=1;
    }else if(tag==2){
        LZHMyThread *myThread=_myThreadsDataArray[tag-1][indexPath.row];
        postViewController.tid=myThread.tid;
        postViewController.page=1;
        postViewController.URLString=@"";
        postViewController.isRedirect=NO;
        NSLog(@"%@",myThread.tid);
    }else if(tag==3){
        LZHMyPost *myPost=_myThreadsDataArray[tag-1][indexPath.row];
        postViewController.tid=@"";
        postViewController.page=1;
        postViewController.isRedirect=YES;
        postViewController.URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",myPost.URLString];
        NSLog(@"%@",myPost.URLString);
    }else if(tag==4){
        LZHMyFavorite *myFavorite=_myThreadsDataArray[tag-1][indexPath.row];
        postViewController.tid=@"";
        postViewController.page=1;
        postViewController.isRedirect=NO;
        postViewController.URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",myFavorite.URLString];
        NSLog(@"%@",myFavorite.URLString);
    }
    [self.navigationController pushViewController:postViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



@end
