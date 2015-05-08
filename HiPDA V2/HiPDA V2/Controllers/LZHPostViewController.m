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
#import "LZHProfileViewController.h"
#import "IDMPhotoBrowser.h"
#import "SVWebViewController.h"

@interface LZHPostViewController ()

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSMutableArray *postList;
@property (strong, nonatomic) NSString *htmlFormatString;
@property (strong, nonatomic) NSString *defaultUserAvatarImageURLString;

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
    _webView.dataDetectorTypes=UIDataDetectorTypeLink;
    [self pullDownToRefresh];
    [self pullUpToLoadMore];
    
    //初始化参数
    _postList=[[NSMutableArray alloc]init];
    _htmlFormatString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LZHPostList" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    _defaultUserAvatarImageURLString=@"http://www.hi-pda.com/forum/uc_server/data/avatar/000/85/69/99_avatar_middle.jpg?random=10.9496039664372802";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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

//scheme://host:port/path?
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString=[[request URL] absoluteString];
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    if ([[[request URL] scheme]isEqualToString:@"leizh-scheme"]) {
        //用户名，用户头像和帖子信息被点击的时候
        NSString *host=[[request URL]host];
        NSArray *clickedInfoArray=[host componentsSeparatedByString:@"_"];
        //要加2，应为0是帖子标题，1是楼层总数
        LZHPost *clickedPost=(LZHPost *)_postList[[clickedInfoArray[1] integerValue]+2];
        //当用户头像和用户名被点击的时候
        if ([clickedInfoArray[0] isEqualToString:@"username"]||[clickedInfoArray[0] isEqualToString:@"avatar"]) {
            //NSLog(@"userName:%@ uid:%@",clickedPost.user.userName,clickedPost.user.uid);
            LZHProfileViewController *profileViewControlle=[[LZHProfileViewController alloc]init];
            profileViewControlle.user=clickedPost.user;
            [self.navigationController pushViewController:profileViewControlle animated:YES];
        }else if([clickedInfoArray[0] isEqualToString:@"postmessage"]){
            //当帖子内容被点击的时候
            //NSLog(@"postmessage %@",clickedPost.postMessage);
            UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"回复"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"引用"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"用户信息"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"加为好友"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"发短消息"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"只看该作者"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                              }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }else if([requestString containsString:@"leizh-scheme:imageClicked_"]){
            NSRange range=[requestString rangeOfString:@"leizh-scheme:imageClicked_"];
            NSString *imageURLString=[requestString substringFromIndex:range.length];
            if ([imageURLString containsString:@"www."]) {
                imageURLString=[NSString stringWithFormat:@"http://%@",imageURLString];
            }else{
                imageURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",imageURLString];
            }
            IDMPhoto *photo=[IDMPhoto photoWithURL:[NSURL URLWithString:imageURLString]];
            IDMPhotoBrowser *browser=[[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:self.view];
            [self presentViewController:browser animated:YES completion:nil];
        }else if([requestString containsString:@"leizh-scheme://linkClicked_"]){
            NSRange range=[requestString rangeOfString:@"leizh-scheme://linkClicked_"];
            NSString *linkURLString=[requestString substringFromIndex:range.length];
            if ([linkURLString containsString:@"realURL"]) {
                linkURLString=[NSString stringWithFormat:@"http://%@",[linkURLString substringFromIndex:7]];
            }else{
                linkURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",linkURLString];
            }
            if ([linkURLString containsString:@"hi-pda"]) {
                
            }else{
                SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:linkURLString];
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            NSLog(@"%@",linkURLString);
        }
    }/*else if([requestString containsString:@"data:image"]){
        NSRange headRange=[requestString rangeOfString:@"data:image/jpeg;base64,"];
        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:[requestString substringFromIndex:headRange.length]options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *clickedImage=[UIImage imageWithData:imageData];
        IDMPhoto *photo=[IDMPhoto photoWithImage:clickedImage];
        IDMPhotoBrowser *browser=[[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:self.view];
        browser.scaleImage=clickedImage;
        [self presentViewController:browser animated:YES completion:nil];
    }*/
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

#pragma mark - UITableView  下拉刷新 自定义文字
- (void)pullDownToRefresh
{
    [_webView.scrollView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [_webView.scrollView.header setTitle:@"下拉可以刷新" forState:MJRefreshHeaderStateIdle];
    [_webView.scrollView.header setTitle:@"松开立即刷新" forState:MJRefreshHeaderStatePulling];
    [_webView.scrollView.header setTitle:@"正在刷新数据中..." forState:MJRefreshHeaderStateRefreshing];
    
    _webView.scrollView.header.font = [UIFont systemFontOfSize:15];
    
    [_webView.scrollView.header beginRefreshing];
    
}

#pragma mark UITableView + 上拉刷新 自定义文字
- (void)pullUpToLoadMore
{
    [_webView.scrollView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [_webView.scrollView.footer setTitle:@"点击加载更多" forState:MJRefreshFooterStateIdle];
    [_webView.scrollView.footer setTitle:@"正在加载更多的数据" forState:MJRefreshFooterStateRefreshing];
    [_webView.scrollView.footer setTitle:@"没有更多的数据了" forState:MJRefreshFooterStateNoMoreData];
    
    _webView.scrollView.footer.font = [UIFont systemFontOfSize:15];
    
    _webView.scrollView.footer.automaticallyRefresh=NO;
}

#pragma mark - 数据处理相关

- (void)loadNewData
{
    [_webView stopLoading];
    __weak typeof(self) weakSelf=self;
    [LZHPost loadPostTid:_tid page:_page completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            weakSelf.postList=[array mutableCopy];
            [weakSelf prepareDataForUIWebView];
            [weakSelf.webView.scrollView.header endRefreshing];
            self.page=_page;
        }
    }];
}


- (void)loadMoreData
{
    [_webView.scrollView.footer endRefreshing];
}


#pragma mark - prepare data for UIWebView
-(void)prepareDataForUIWebView{
    __block NSString *htmlString=@"";
    __weak typeof(self) weakSelf=self;
    NSString *html=@"";
    [_postList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx==0) {
            NSString *title=(NSString *)obj;
            if (![title isEqualToString:@""]) {
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"title\">%@</div>",title];
            }
        }else if(idx>1){
            LZHPost *post=(LZHPost *)obj;
            if (post.isBlocked) {
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%ld\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" onclick=\"postClicked(this);\" id=\"avatar_%ld\"><img src=\"%@\" onerror=\"this.src='%@';\"></img></span><span class=\"username\" onclick=\"postClicked(this);\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" id=\"postmessage_%ld\"><span class=\"blocked\">该用户已被您屏蔽！</span></div></div>",idx-2,idx-2,idx-2,[post.user.avatarImageURL absoluteString],weakSelf.defaultUserAvatarImageURLString,idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2];
            }else{
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%ld\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" onclick=\"postClicked(this);\" id=\"avatar_%ld\"><img src=\"%@\" onerror=\"this.src='%@';\"></img></span><span class=\"username\" onclick=\"postClicked(this);\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" onclick=\"postClicked(this);\" id=\"postmessage_%ld\">%@</div></div>",idx-2,idx-2,idx-2,[post.user.avatarImageURL absoluteString],weakSelf.defaultUserAvatarImageURLString,idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2,post.postMessage];
            }
        }
    }];
    @autoreleasepool {
        html=[_htmlFormatString copy];
        html=[html stringByReplacingOccurrencesOfString:@"###content here###" withString:htmlString];
        [_webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.hi-pda.com/forum/"]];
    }
}

@end
