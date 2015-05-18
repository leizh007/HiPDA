//
//  LZHPersonalMessageViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/12.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPersonalMessageViewController.h"
#import "HMSegmentedControl.h"
#import "UIImage+LZHHIPDA.h"
#import "MJRefresh.h"
#import "LZHNotice.h"
#import "MJRefresh.h"
#import "LZHPrompt.h"
#import "LZHShowMessage.h"
#import "LZHPromptPmTableViewCell.h"
#import "LZHPrompt.h"
#import "LZHUser.h"
#import "SVProgressHUD.h"
#import "LZHNetworkFetcher.h"
#import "LZHMessagesViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZHAccount.h"

#define kBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.5]

const NSInteger kPromptPmTag=1;
const NSInteger kPromptAnnouncepmTag=2;
const NSInteger kPromptSystemPmTag=3;
const NSInteger kPromptFriendTag=4;

@interface LZHPersonalMessageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIImage *promptPmImage;
@property (strong, nonatomic) UIImage *promptAnnouncepmImage;
@property (strong, nonatomic) UIImage *promptSystemPmImage;
@property (strong, nonatomic) UIImage *promptFriendImage;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray *tableViewArray;
@property (strong, nonatomic) NSMutableArray *promptDataArray;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign ,nonatomic) CGFloat viewWidth;
@property (assign, nonatomic) CGFloat viewHeight;
@property (assign, nonatomic) NSInteger selectedSegmentedIndex;

@end

@implementation LZHPersonalMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化参数
    _selectedSegmentedIndex=0;
    _viewWidth=[[UIScreen mainScreen]bounds].size.width;
    self.navigationItem.title=@"短消息";
    NSArray *array=@[[NSNull null],[NSNull null],[NSNull null],[NSNull null]];
    _promptDataArray=[[NSMutableArray alloc]initWithArray:array];
    [self updateSegmentedControl];
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, _segmentedControl.frame.origin.y+_segmentedControl.frame.size.height, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-_segmentedControl.frame.origin.y-_segmentedControl.frame.size.height)];
    _scrollView.backgroundColor=[UIColor grayColor];
    _scrollView.backgroundColor = kBackgroundColor;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_viewWidth * 4, 200);
    _scrollView.delegate = self;
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, _viewWidth, _viewHeight) animated:NO];
    [self.view addSubview:self.scrollView];
    _viewHeight=_scrollView.frame.size.height;
    
    _tableViewArray=[[NSMutableArray alloc]init];
    __weak typeof(self) weakSelf=self;
    for (int i=0; i<4; ++i) {
        UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(_viewWidth*i, 0, _viewWidth, _viewHeight)];
        tableView.tag=i+1;
        tableView.delegate=self;
        tableView.dataSource=self;
        tableView.tableFooterView=[[UIView alloc]init];
        tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [tableView addLegendHeaderWithRefreshingBlock:^{
            [weakSelf loadNewDataWithTag:i+1];
        }];
        [_scrollView addSubview:tableView];
        if (i==0) {
            [tableView.header beginRefreshing];
        }
        [_tableViewArray addObject:tableView];
    }
    
    //注册KVO
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice addObserver:self forKeyPath:@"promptPm" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [notice addObserver:self forKeyPath:@"promptAnnouncepm" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [notice addObserver:self forKeyPath:@"promptSystemPm" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [notice addObserver:self forKeyPath:@"promptFriend" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    //注册KVO
    LZHNotice *notice=[LZHNotice sharedNotice];
    [notice removeObserver:self forKeyPath:@"promptPm"];
    [notice removeObserver:self forKeyPath:@"promptAnnouncepm"];
    [notice removeObserver:self forKeyPath:@"promptSystemPm"];
    [notice removeObserver:self forKeyPath:@"promptFriend"];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"promptPm"]||[keyPath isEqualToString:@"promptAnnouncepm"]||[keyPath isEqualToString:@"promptSystemPm"]||[keyPath isEqualToString:@"promptFriend"]) {
        [self updateSegmentedControl];
    }
}

#pragma mark - HMSegmentedControl
-(void)updateSegmentedControl{
    LZHNotice *notice=[LZHNotice sharedNotice];
    _promptPmImage=[UIImage segmentedImageWithTitle:@"私人消息" badgeValue:notice.promptPm];
    _promptAnnouncepmImage=[UIImage segmentedImageWithTitle:@"公共消息" badgeValue:notice.promptAnnouncepm];
    _promptSystemPmImage=[UIImage segmentedImageWithTitle:@"系统消息" badgeValue:notice.promptSystemPm];
    _promptFriendImage=[UIImage segmentedImageWithTitle:@"好友消息" badgeValue:notice.promptFriend];
    if (_segmentedControl.superview!=nil) {
        [_segmentedControl removeFromSuperview];
    }
    _segmentedControl=[[HMSegmentedControl alloc] initWithSectionImages:@[_promptPmImage,_promptAnnouncepmImage,_promptSystemPmImage,_promptFriendImage] sectionSelectedImages:@[_promptPmImage,_promptAnnouncepmImage,_promptSystemPmImage,_promptFriendImage]];
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

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger tag=tableView.tag;
    if (![_promptDataArray[tag-1] isEqual:[NSNull null]]) {
        return [_promptDataArray[tag-1] count];
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag=tableView.tag;
    NSString *reusableCellWithIdentifier=[NSString stringWithFormat:@"reusableCellWithIdentifier+%ld",tag];
    LZHPromptPmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell=[[LZHPromptPmTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    [(LZHPromptPmTableViewCell *)cell configurePrompt:_promptDataArray[tag-1][indexPath.row]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag=tableView.tag;
    if (![_promptDataArray[tag-1] isEqual:[NSNull null]]) {
        return [LZHPromptPmTableViewCell cellHeightForPrompt:_promptDataArray[tag-1][indexPath.row]];
    }
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger tag=tableView.tag;
    if (tag==kPromptFriendTag) {
        LZHPrompt *prompt=_promptDataArray[tag-1][indexPath.row];
        [self showAddFriendAlertWithUser:prompt.user andURLString:prompt.URLString];
    }else if(tag==kPromptPmTag){
        LZHPrompt *prompt=_promptDataArray[tag-1][indexPath.row];
        LZHMessagesViewController *messagesViewController=[[LZHMessagesViewController alloc]init];
        messagesViewController.friend=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:prompt.user.uid,
                                                                           LZHUSERUSERNAME:prompt.user.userName}];
        messagesViewController.dateRange=5;
        __weak typeof(self) weakSelf=self;
        SDWebImageManager *manager=[SDWebImageManager sharedManager];
        [manager downloadImageWithURL:prompt.user.avatarImageURL
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (error!=nil) {
                                    messagesViewController.friendAvatar=[UIImage imageNamed:@"avatar"];
                                }else{
                                    messagesViewController.friendAvatar=image;
                                }
                                LZHAccount *account=[LZHAccount sharedAccount];
                                NSDictionary *accountInfo=[account account];
                                messagesViewController.myAvatar=accountInfo[LZHACCOUNTUSERAVATAR];
                                [weakSelf.navigationController pushViewController:messagesViewController animated:YES];
                            }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AlertController

-(void)showAddFriendAlertWithUser:(LZHUser *)user andURLString:(NSString *)URLString{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"加好友"
                                                                           message:[NSString stringWithFormat:@"是否添加%@为好友？",user.userName]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SVProgressHUD showWithStatus:@"正在发送请求..." maskType:SVProgressHUDMaskTypeGradient];
        [LZHNetworkFetcher beFriendToUser:user withURLString:URLString completionHandler:^(NSArray *array, NSError *error) {
            if (error!=nil) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
            }else{
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:array[0]];
            }
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    __weak typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - 数据处理相关

- (void)loadNewDataWithTag:(NSInteger)tag
{
    NSString *URLString;
    switch (tag) {
        case 1:
            URLString=@"http://www.hi-pda.com/forum/pm.php?filter=privatepm";
            break;
        case 2:
            URLString=@"http://www.hi-pda.com/forum/pm.php?filter=announcepm";
            break;
        case 3:
            URLString=@"http://www.hi-pda.com/forum/notice.php?filter=systempm";
            break;
        case 4:
            URLString=@"http://www.hi-pda.com/forum/notice.php?filter=friend";
            break;
        default:
            return;
            break;
    }
    __weak typeof(self) weakSelf=self;
    [LZHPrompt getPmURLString:URLString completionHandler:^(NSArray *array, NSError *error) {
        UITableView *tableView=(UITableView*)[weakSelf.scrollView viewWithTag:tag];
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            if (array.count==0) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"暂无数据"];
                weakSelf.promptDataArray[tag-1]=[NSNull null];
            }else{
                weakSelf.promptDataArray[tag-1]=array;
            }
        }
        [tableView.header endRefreshing];
        [tableView reloadData];
    }];
}


- (void)loadMoreData
{
    
}

-(void)tableViewHeaderEndRefreshing{
    [_tableViewArray enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL *stop) {
        [tableView.header endRefreshing];
    }];
}
@end
