//
//  LZHPostViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/1.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHPostViewController.h"
#import "MTLog.h"
#import "MJRefresh.h"
#import "LZHPost.h"
#import "LZHNetworkFetcher.h"
#import "LZHHtmlParser.h"
#import "LZHShowMessage.h"
#import "LZHUser.h"
#import "NSString+LZHHIPDA.h"

@interface LZHPostViewController ()

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSMutableArray *postList;
@property (strong, nonatomic) NSString *htmlFormatString;
@property (assign, nonatomic) NSInteger contentOffsetY;

@end

@implementation LZHPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //设置webView
    _webView=[[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.delegate=self;
    [self.view addSubview:_webView];
    self.view.backgroundColor=[UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1.0];
    _webView.backgroundColor= [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1.0];
    _webView.opaque=NO;
    _webView.dataDetectorTypes=UIDataDetectorTypeNone;
    [self pullDownToRefresh];
    [self pullUpToLoadMore];
    
    //初始化参数
    _postList=[[NSMutableArray alloc]init];
    _htmlFormatString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LZHPostList" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    _contentOffsetY=0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)setPage:(NSInteger)page{
    _page=page;
    
    //根据是否是最后一页设置footer的内容
    if ([_postList count]!=0) {
        NSInteger totalPage=[(NSString *)_postList[1] integerValue];
        if (_page==totalPage) {
            [_webView.scrollView.footer noticeNoMoreData];
        }else{
            [_webView.scrollView.footer resetNoMoreData];
        }
    }
}


#pragma mark - UIWebView Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    NSLog(@"%@",[[request URL] absoluteString]);
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"%@",[[request URL] absoluteString]);
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_contentOffsetY!=0&&_contentOffsetY!=-118) {
        _webView.scrollView.contentOffset=CGPointMake(0, _contentOffsetY);
    }
}

#pragma mark - UITableView  下拉刷新 自定义文字
- (void)pullDownToRefresh
{
    [_webView.scrollView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [_webView.scrollView.header setTitle:@"Pull down to refresh" forState:MJRefreshHeaderStateIdle];
    [_webView.scrollView.header setTitle:@"Release to refresh" forState:MJRefreshHeaderStatePulling];
    [_webView.scrollView.header setTitle:@"Loading ..." forState:MJRefreshHeaderStateRefreshing];
    
    _webView.scrollView.header.font = [UIFont systemFontOfSize:15];
    
    [_webView.scrollView.header beginRefreshing];
    
}

#pragma mark UITableView + 上拉刷新 自定义文字
- (void)pullUpToLoadMore
{
    [_webView.scrollView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [_webView.scrollView.footer setTitle:@"Click or drag up to refresh" forState:MJRefreshFooterStateIdle];
    [_webView.scrollView.footer setTitle:@"Loading more ..." forState:MJRefreshFooterStateRefreshing];
    [_webView.scrollView.footer setTitle:@"No more data" forState:MJRefreshFooterStateNoMoreData];
    
    _webView.scrollView.footer.font = [UIFont systemFontOfSize:15];

}

#pragma mark - 数据处理相关

- (void)loadNewData
{
    __weak typeof(self) weakSelf=self;
    [LZHPost loadPostTid:_tid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            weakSelf.postList=[array mutableCopy];
            [weakSelf prepareDataForUIWebView];
            [weakSelf.webView.scrollView.header endRefreshing];
            [weakSelf replacePostMessageContent];
            weakSelf.webView.scrollView.header.hidden=YES;
        }
    }];
}


- (void)loadMoreData
{
    [_webView.scrollView.footer endRefreshing];
}

#pragma  mark - 数据转换

-(void)replacePostMessageContent{
    __block BOOL isDataChanged=NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_postList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx>=2) {
                NSString *postMessage=[((LZHPost *)obj).postMessage replacePostContent];
                if (![postMessage isEqualToString:((LZHPost *)obj).postMessage]) {
                    ((LZHPost *)obj).postMessage=postMessage;
                    isDataChanged=YES;
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isDataChanged) {
                [self prepareDataForUIWebView];
            }
            _webView.scrollView.header.hidden=NO;
        });
    });
    
}

#pragma mark - prepare data for UIWebView
-(void)prepareDataForUIWebView{
    __block NSString *htmlString=@"";
    __block NSString *html=@"";
    _contentOffsetY=_webView.scrollView.contentOffset.y;
    [_postList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx==0) {
            NSString *title=(NSString *)obj;
            if (![title isEqualToString:@""]) {
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"title\">%@</div>",title];
            }
        }else if(idx>1){
            LZHPost *post=(LZHPost *)obj;
            if (post.isBlocked) {
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%ld\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" id=\"avatar_%ld\"><img src=\"%@\"></img></span><span class=\"username\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" id=\"postmessage_%ld\"><span class=\"blocked\">该用户已被您屏蔽！</span></div></div>",idx-2,idx-2,idx-2,[post.user.avatarImageURL absoluteString],idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2];
            }else{
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%ld\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" id=\"avatar_%ld\"><img src=\"%@\"></img></span><span class=\"username\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" id=\"postmessage_%ld\">%@</div></div>",idx-2,idx-2,idx-2,[post.user.avatarImageURL absoluteString],idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2,post.postMessage];
            }
        }
    }];
    html=[_htmlFormatString copy];
    html=[html stringByReplacingOccurrencesOfString:@"###content here###" withString:htmlString];
    [_webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.hi-pda.com/forum/"]];
}

@end
