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
#import "NJKWebViewProgress.h"
#import "LZHHtmlParser.h"
#import "LZHHTTPRequestOperationManager.h"
#import "MTLog.h"
#import "UIViewController+KNSemiModal.h"
#import "LZHAddFavorite.h"
#import "LZHReplyViewController.h"

static const CGFloat kDistanceBetweenViews=8.0f;
static const CGFloat kButtonWidth=18.0f;

@interface LZHPostViewController ()

@property (strong, nonatomic) UIWebView      *webView;
@property (strong, nonatomic) NSMutableArray *postList;
@property (strong, nonatomic) NSString       *htmlFormatString;
@property (strong, nonatomic) NSString       *defaultUserAvatarImageURLString;
@property (assign, nonatomic) NSInteger      totalPageNumber;
@property (strong, nonatomic) UIView         *changePageNumberView;
@property (strong, nonatomic) UIButton       *changePageNumberButton;
@property (strong, nonatomic) UIButton       *addFavoriteButton;
@property (strong, nonatomic) UIImageView    *addFavoriteImageView;
@property (strong, nonatomic) UIButton       *replyButton;
@property (strong, nonatomic) UIImageView    *replyImageView;

@property (strong, nonatomic) UISlider *pageSlider;
@property (strong, nonatomic) UIButton *goButton;
@property (strong, nonatomic) UIButton *previousPageButton;
@property (strong, nonatomic) UIButton *firstPageButton;
@property (strong, nonatomic) UIButton *nextPageButton;
@property (strong, nonatomic) UIButton *lastPageButton;
@property (strong, nonatomic) UILabel  *pageLabel;

@property (assign, nonatomic) BOOL isPullDownToRefresh;

@property (copy, nonatomic) NSString *fid;

@end

@implementation LZHPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _totalPageNumber=1;
    
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
    
    //设置navigationBarItem
    _changePageNumberButton=[[UIButton alloc]init];
    [_changePageNumberButton addTarget:self action:@selector(changePageNumberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_changePageNumberButton setTitle:[NSString stringWithFormat:@"%ld/%ld",_page,_totalPageNumber] forState:UIControlStateNormal];
    [self setButtonTitleColor:_changePageNumberButton];
    [_changePageNumberButton sizeToFit];
    _changePageNumberButton.frame=CGRectMake(0, 0, _changePageNumberButton.frame.size.width*3, _changePageNumberButton.frame.size.height);
    _changePageNumberButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *changePageNumberButtonIterm=[[UIBarButtonItem alloc]initWithCustomView:_changePageNumberButton];
    
    _addFavoriteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _addFavoriteImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"favorite"] highlightedImage:[UIImage imageNamed:@"favorite_highlighted"]];
    _addFavoriteImageView.frame=CGRectMake(kButtonWidth/2, 0, kButtonWidth, kButtonWidth);
    _addFavoriteImageView.contentMode=UIViewContentModeScaleToFill;
    _addFavoriteButton.frame=CGRectMake(0, 0, kButtonWidth*2, kButtonWidth);
    [_addFavoriteButton addSubview:_addFavoriteImageView];
    [_addFavoriteButton addTarget:self action:@selector(addFavoritedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addFavoriteButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_addFavoriteButton];
    
    _replyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _replyImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"replyBlue"] highlightedImage:[UIImage imageNamed:@"replyBlueHighlighed"]];
    _replyImageView.contentMode=UIViewContentModeScaleToFill;
    _replyImageView.frame=CGRectMake(0, 0, kButtonWidth, kButtonWidth);
    _replyButton.frame=CGRectMake(0, 0, kButtonWidth, kButtonWidth);
    [_replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_replyButton addSubview:_replyImageView];
    UIBarButtonItem *replyBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:_replyButton];
    
    self.navigationItem.rightBarButtonItems=@[replyBarButtonItem,addFavoriteButtonItem,changePageNumberButtonIterm];
    
    //初始化参数
    _postList=[[NSMutableArray alloc]init];
    _htmlFormatString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LZHPostList" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    _defaultUserAvatarImageURLString=@"http://www.hi-pda.com/forum/uc_server/data/avatar/000/85/69/99_avatar_middle.jpg?random=10.9496039664372802";
    _changePageNumberView=self.changePageNumberView;
    _isPullDownToRefresh=NO;
    
    if ([_tid isEqualToString:@""]) {
        [self getPostParamters];
    }else{
        [_webView.scrollView.header beginRefreshing];
    }
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

-(void)setButtonTitleColor:(UIButton *)button{
    [button setTitleColor:[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0 green:0.459 blue:1 alpha:0.2] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithRed:0.708 green:0.73 blue:0.71 alpha:1] forState:UIControlStateDisabled];
}

#pragma mark - setter & getter

-(void)setPage:(NSInteger)page{
    _page=page;
    [_changePageNumberButton setTitle:[NSString stringWithFormat:@"%ld/%ld",_page,_totalPageNumber] forState:UIControlStateNormal];
    if (page==1) {
        _previousPageButton.enabled=NO;
    }else{
        _previousPageButton.enabled=YES;
    }
    //根据是否是最后一页设置footer的内容
    if ([_postList count]!=0) {
        if (_page>=_totalPageNumber) {
            _totalPageNumber=_page;
            [_webView.scrollView.footer noticeNoMoreData];
            _nextPageButton.enabled=NO;
        }else{
            [_webView.scrollView.footer resetNoMoreData];
            _nextPageButton.enabled=YES;
        }
    }
}

-(void)setTotalPageNumber:(NSInteger)totalPageNumber{
    if (totalPageNumber>_totalPageNumber) {
        _totalPageNumber=totalPageNumber;
        [_changePageNumberButton setTitle:[NSString stringWithFormat:@"%ld/%ld",_page,_totalPageNumber] forState:UIControlStateNormal];
    }
}

-(UIView*)changePageNumberView{
    if (_changePageNumberView==nil) {
        _changePageNumberView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 200)];
        _changePageNumberView.backgroundColor=[UIColor whiteColor];
        _pageSlider=[[UISlider alloc]init];
        _pageSlider.maximumValue=0.99f;
        _pageSlider.minimumValue=0.0f;
        [_pageSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        _goButton=[[UIButton alloc]init];
        [self setButtonTitleColor:_goButton];
        [_goButton addTarget:self action:@selector(buttonInChangeNumberViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_goButton setTitle:@"GO" forState:UIControlStateNormal];
        [_goButton sizeToFit];
        _goButton.frame=CGRectMake(_changePageNumberView.frame.size.width-kDistanceBetweenViews-_goButton.frame.size.width*2, kDistanceBetweenViews, _goButton.frame.size.width*2, _goButton.frame.size.height);
        [_changePageNumberView addSubview:_goButton];
        
        _pageSlider.frame=CGRectMake(kDistanceBetweenViews, kDistanceBetweenViews, _changePageNumberView.frame.size.width-3*kDistanceBetweenViews-_goButton.frame.size.width, _goButton.frame.size.height);
        [_changePageNumberView addSubview:_pageSlider];
        
        CGFloat buttonWidth=(_changePageNumberView.frame.size.width-4.0f)/5;
        
        _firstPageButton=[[UIButton alloc]init];
        [self setButtonTitleColor:_firstPageButton];
        [_firstPageButton addTarget:self action:@selector(buttonInChangeNumberViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_firstPageButton setTitle:@"首  页" forState:UIControlStateNormal];
        _firstPageButton.frame=CGRectMake(0, _pageSlider.frame.origin.y+_pageSlider.frame.size.height+kDistanceBetweenViews, buttonWidth, _goButton.frame.size.height);
        [_changePageNumberView addSubview:_firstPageButton];
        
        _previousPageButton=[[UIButton alloc]init];
        [self setButtonTitleColor:_previousPageButton];
        [_previousPageButton setTitle:@"前一页" forState:UIControlStateNormal];
        _previousPageButton.frame=CGRectMake(buttonWidth+1.0f, _firstPageButton.frame.origin.y, buttonWidth, _firstPageButton.frame.size.height);
        [_previousPageButton addTarget:self action:@selector(buttonInChangeNumberViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_changePageNumberView addSubview:_previousPageButton];
        
        _pageLabel=[[UILabel alloc]init];
        _pageLabel.textColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1];
        _pageLabel.frame=CGRectMake(buttonWidth*2+2.0f, _previousPageButton.frame.origin.y, buttonWidth, _previousPageButton.frame.size.height);
        _pageLabel.textAlignment=NSTextAlignmentCenter;
        [_changePageNumberView addSubview:_pageLabel];
        
        _nextPageButton=[[UIButton alloc]init];
        [self setButtonTitleColor:_nextPageButton];
        [_nextPageButton setTitle:@"下一页" forState:UIControlStateNormal];
        _nextPageButton.frame=CGRectMake(3*buttonWidth+3.0, _pageLabel.frame.origin.y, buttonWidth, _pageLabel.frame.size.height);
        [_nextPageButton addTarget:self action:@selector(buttonInChangeNumberViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_changePageNumberView addSubview:_nextPageButton];
        
        _lastPageButton=[[UIButton alloc ]init];
        [self setButtonTitleColor:_lastPageButton];
        [_lastPageButton setTitle:@"尾  页" forState:UIControlStateNormal];
        _lastPageButton.frame=CGRectMake(4*buttonWidth+4.0f, _nextPageButton.frame.origin.y, buttonWidth, _nextPageButton.frame.size.height);
        [_lastPageButton addTarget:self action:@selector(buttonInChangeNumberViewPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_changePageNumberView addSubview:_lastPageButton];
        
        UILabel *seperatorUpLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _firstPageButton.frame.origin.y-1, _changePageNumberView.frame.size.width, 1.0f)];
        seperatorUpLabel.backgroundColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:0.8];
        [_changePageNumberView addSubview:seperatorUpLabel];
        
        UILabel *seperatorDownLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _firstPageButton.frame.origin.y+_firstPageButton.frame.size.height+1, _changePageNumberView.frame.size.width, 1.0f)];
        seperatorDownLabel.backgroundColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:0.8];
        [_changePageNumberView addSubview:seperatorDownLabel];
        
        _changePageNumberView.frame=CGRectMake(0, 0, _changePageNumberView.frame.size.width, seperatorDownLabel.frame.origin.y+1.0);
        
        for (int i=0; i<4; ++i) {
            UILabel *seperatorLabel=[[UILabel alloc] initWithFrame:CGRectMake((i+1)*buttonWidth, _firstPageButton.frame.origin.y, 1.0, _firstPageButton.frame.size.height)];
            seperatorLabel.backgroundColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:0.8];
            [_changePageNumberView addSubview:seperatorLabel];
        }
    }
    _pageSlider.value=(CGFloat)_page/(CGFloat)_totalPageNumber;
    _pageLabel.text=[NSString stringWithFormat:@"%ld/%ld",_page,_totalPageNumber];
    return _changePageNumberView;
}

#pragma mark - Button Pressed

-(void)replyButtonPressed:(UIButton *)button{
    _replyImageView.highlighted=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _replyImageView.highlighted=NO;
    });
    [self presentReplyViewControllerWithPid:@"" replyType:LZHreplyTypeNewPost];
}

-(void)changePageNumberButtonPressed:(id)sender{
    [self presentSemiView:self.changePageNumberView withOptions:@{
                                                              KNSemiModalOptionKeys.pushParentBack : @(NO),
                                                              KNSemiModalOptionKeys.parentAlpha : @(0.8),
                                                              }];
}

-(void)addFavoritedButtonPressed:(UIButton *)button{
    _addFavoriteImageView.highlighted=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _addFavoriteImageView.highlighted=NO;
    });
    [SVProgressHUD showWithStatus:@"与服务器通讯..." maskType:SVProgressHUDMaskTypeGradient];
    [LZHAddFavorite addFavoriteTid:_tid completionHandler:^(NSArray *array, NSError *error) {
        if (error) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:array[0]];
            _addFavoriteImageView.image=[UIImage imageNamed:@"favorited"];
            button.enabled=NO;
        }
    }];
    
}

-(void)sliderValueChanged:(UISlider *)slider{
    _pageLabel.text=[NSString stringWithFormat:@"%ld/%ld",(NSInteger)(slider.value*_totalPageNumber)+1,_totalPageNumber];
}

-(void)buttonInChangeNumberViewPressed:(UIButton *)button{
    NSInteger page;
    if (button==_goButton) {
        page=(NSInteger)(_pageSlider.value*_totalPageNumber)+1;
    }else if(button==_firstPageButton){
        page=1;
    }else if(button==_previousPageButton){
        page=_page-1;
    }else if(button==_nextPageButton){
        page=_page+1;
    }else if(button==_lastPageButton){
        page=_totalPageNumber;
    }
    [self dismissSemiModalView];
    self.page=page;
    _isPullDownToRefresh=NO;
    [_webView.scrollView.header beginRefreshing];
}

#pragma mark - Get Redirected URL

-(void)getPostParamters{
    [SVProgressHUD showWithStatus:@"正在获取帖子列表参数..." maskType:SVProgressHUDMaskTypeGradient];
    if (!_isRedirect) {
        [self extractPostParameters];
    }else{
        __weak typeof(self) weakSelf=self;
        AFHTTPRequestOperation *requestOperation=[[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_URLString]]];
        [requestOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
            if (redirectResponse) {
                //NSLog(@"%@",request.URL);
                weakSelf.URLString=[request.URL absoluteString];
            }else{
                weakSelf.URLString=[request.URL absoluteString];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self extractPostParameters];
            });
            return request;
        }];
        [requestOperation start];
    }
}

-(void)extractPostParameters{
    NSArray *postInfoArray=[LZHHtmlParser extractPostInfoFromURLString:_URLString];
    if (postInfoArray.count==1) {
        [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[postInfoArray[0] localizedDescription]];
    }else{
        _tid=postInfoArray[0];
        _page=[postInfoArray[1] integerValue];
        _pid=postInfoArray[2];
        [SVProgressHUD dismiss];
        [_webView.scrollView.header beginRefreshing];
    }
}

-(void)presentReplyViewControllerWithPid:(NSString *)pid replyType:(LZHReplyType)replyType{
    LZHReplyViewController *replyViewController=[[LZHReplyViewController alloc]init];
    replyViewController.fid=_fid;
    replyViewController.page=_page;
    replyViewController.pid=pid;
    replyViewController.replyType=replyType;
    replyViewController.tid=_tid;
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:replyViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UIWebView Delegate

//scheme://host:port/path?
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    __weak typeof(self)weakSelf=self;
    NSString *requestString=[[request URL] absoluteString];
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    if ([[[request URL] scheme]isEqualToString:@"leizh-scheme"]) {
        //用户名，用户头像和帖子信息被点击的时候
        NSString *host=[[request URL]host];
        NSArray *clickedInfoArray=[host componentsSeparatedByString:@"_"];
        //要加2，应为0是帖子标题，1是楼层数
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
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      NSInteger index=[clickedInfoArray[1] integerValue];
                                                                      LZHPost *post=weakSelf.postList[index+2];
                                                                      [self presentReplyViewControllerWithPid:post.pid replyType:LZHReplyTypeReply];
                                                                  });
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"引用"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      NSInteger index=[clickedInfoArray[1] integerValue];
                                                                      LZHPost *post=weakSelf.postList[index+2];
                                                                      [self presentReplyViewControllerWithPid:post.pid replyType:LZHReplyTypeQuote];
                                                                  });
                                                                  
                                                              }]];
            
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"只看该作者"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  LZHPostViewController *postViewController=[[LZHPostViewController alloc]init];
                                                                  postViewController.tid=@"";
                                                                  postViewController.pid=@"";
                                                                  postViewController.isRedirect=YES;
                                                                  postViewController.page=1;
                                                                  NSInteger index=[clickedInfoArray[1] integerValue];
                                                                  LZHPost *post=weakSelf.postList[index+2];
                                                                  postViewController.URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/viewthread.php?tid=%@&page=%ld&authorid=%@",weakSelf.tid,weakSelf.page,post.user.uid];
                                                                  [weakSelf.navigationController pushViewController:postViewController animated:YES];
                                                                  
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
            browser.usePopAnimation=NO;
            [self presentViewController:browser animated:YES completion:nil];
        }else if([requestString containsString:@"leizh-scheme://linkClicked_"]){
            NSRange range=[requestString rangeOfString:@"leizh-scheme://linkClicked_"];
            NSString *linkURLString=[requestString substringFromIndex:range.length];
            if ([linkURLString containsString:@"realURL"]) {
                if ([linkURLString containsString:@"realSSSSS"]) {
                    linkURLString=[NSString stringWithFormat:@"https://%@",[linkURLString substringFromIndex:7]];
                    NSRange ssssRange=[linkURLString rangeOfString:@"realSSSSS"];
                    linkURLString=[linkURLString substringToIndex:ssssRange.location];
                }else{
                    linkURLString=[NSString stringWithFormat:@"http://%@",[linkURLString substringFromIndex:7]];
                }
            }else{
                linkURLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/%@",linkURLString];
            }
            if ([linkURLString containsString:@"hi-pda"]) {
                LZHPostViewController *postViewController=[[LZHPostViewController alloc]init];
                postViewController.tid=@"";
                postViewController.pid=@"";
                postViewController.page=1;
                postViewController.isRedirect=YES;
                postViewController.URLString=linkURLString;
                [self.navigationController pushViewController:postViewController animated:YES];
            }else{
                SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:linkURLString];
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            //NSLog(@"%@",linkURLString);
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
    if (![_pid isEqualToString:@""]) {
        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='#post_%@';",_pid]];
        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById(\"post_%@\").style.backgroundColor='#ECECEC';",_pid]];
        _pid=@"";
    }
}

#pragma mark - UITableView  下拉刷新 自定义文字
- (void)pullDownToRefresh
{
    [_webView.scrollView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [_webView.scrollView.header setTitle:@"下拉可以刷新" forState:MJRefreshHeaderStateIdle];
    [_webView.scrollView.header setTitle:@"松开立即刷新" forState:MJRefreshHeaderStatePulling];
    [_webView.scrollView.header setTitle:@"正在刷新数据中..." forState:MJRefreshHeaderStateRefreshing];
    
    _webView.scrollView.header.font = [UIFont systemFontOfSize:15];
    
}

#pragma mark UITableView + 上拉刷新 自定义文字
- (void)pullUpToLoadMore
{
    [_webView.scrollView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [_webView.scrollView.footer setTitle:@"点击加载下一页" forState:MJRefreshFooterStateIdle];
    [_webView.scrollView.footer setTitle:@"正在加载下一页的数据" forState:MJRefreshFooterStateRefreshing];
    [_webView.scrollView.footer setTitle:@"没有更多的数据了" forState:MJRefreshFooterStateNoMoreData];
    
    _webView.scrollView.footer.font = [UIFont systemFontOfSize:15];
    
    _webView.scrollView.footer.automaticallyRefresh=NO;
}

#pragma mark - 数据处理相关

- (void)loadNewData
{
    NSInteger page;
    if (_isPullDownToRefresh) {
        page=_page>1?_page-1:1;
    }else{
        page=_page;
    }
    [_webView stopLoading];
    __weak typeof(self) weakSelf=self;
    [LZHPost loadPostTid:_tid page:page fullURLString:_URLString completionHandler:^(NSArray *array, NSError *error) {
        [weakSelf.webView.scrollView.header endRefreshing];
        weakSelf.isPullDownToRefresh=YES;
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            NSMutableArray *mutableArray=[array mutableCopy];
            if ([mutableArray[0] isEqualToString:@""]) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"无法获取fid！"];
            }else{
                weakSelf.fid=mutableArray[0];
                [mutableArray removeObjectAtIndex:0];
            }
            weakSelf.URLString=@"";
            weakSelf.isRedirect=NO;
            weakSelf.postList=mutableArray;
            [weakSelf prepareDataForUIWebView];
            NSInteger totalPage=[(NSString *)_postList[1] integerValue];
            weakSelf.totalPageNumber=totalPage;
            weakSelf.page=page;
            [weakSelf setScrollViewHeaderIsPageEqualOne:page==1];
        }
    }];
}


- (void)loadMoreData
{
    NSInteger page=_page+1;
    [_webView stopLoading];
    __weak typeof(self) weakSelf=self;
    [LZHPost loadPostTid:_tid page:page fullURLString:_URLString completionHandler:^(NSArray *array, NSError *error) {
        [_webView.scrollView.footer endRefreshing];
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            weakSelf.URLString=@"";
            weakSelf.isRedirect=NO;
            weakSelf.postList=[array mutableCopy];
            [weakSelf prepareDataForUIWebView];

            NSInteger totalPage=[(NSString *)_postList[1] integerValue];
            weakSelf.totalPageNumber=totalPage;
            weakSelf.page=page;
            [weakSelf setScrollViewHeaderIsPageEqualOne:page==1];
        }
    }];
    
}

-(void)setScrollViewHeaderIsPageEqualOne:(BOOL)isOne{
    if (isOne) {
        [_webView.scrollView.header setTitle:@"下拉可以刷新" forState:MJRefreshHeaderStateIdle];
        [_webView.scrollView.header setTitle:@"松开立即刷新" forState:MJRefreshHeaderStatePulling];
        [_webView.scrollView.header setTitle:@"正在刷新数据中..." forState:MJRefreshHeaderStateRefreshing];
    }else{
        [_webView.scrollView.header setTitle:@"下拉加载上一页" forState:MJRefreshHeaderStateIdle];
        [_webView.scrollView.header setTitle:@"松开加载上一页" forState:MJRefreshHeaderStatePulling];
        [_webView.scrollView.header setTitle:@"正在加载数据中..." forState:MJRefreshHeaderStateRefreshing];
    }
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
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%@\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" onclick=\"postClicked(this);\" id=\"avatar_%ld\"><img src=\"%@\" onerror=\"this.src='%@';\"></img></span><span class=\"username\" onclick=\"postClicked(this);\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" id=\"postmessage_%ld\"><span class=\"blocked\">该用户已被您屏蔽！</span></div></div>",post.pid,idx-2,idx-2,[post.user.avatarImageURL absoluteString],weakSelf.defaultUserAvatarImageURLString,idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2];
            }else{
                htmlString=[htmlString stringByAppendingFormat:@"<div class=\"post\" id=\"post_%@\"><div class=\"postinfo\" id=\"postinfo_%ld\"><span class=\"avatar\" onclick=\"postClicked(this);\" id=\"avatar_%ld\"><img src=\"%@\" onerror=\"this.src='%@';\"></img></span><span class=\"username\" onclick=\"postClicked(this);\" id=\"username_%ld\">%@</span><span class=\"posttime\" id=\"posttime_%ld\">%@</span><span class=\"floor\" id=\"floor_%ld\">%ld#</span></div><div class=\"postmessage\" onclick=\"postClicked(this);\" id=\"postmessage_%ld\">%@</div></div>",post.pid,idx-2,idx-2,[post.user.avatarImageURL absoluteString],weakSelf.defaultUserAvatarImageURLString,idx-2,post.user.userName,idx-2,post.postTime,idx-2,post.floor,idx-2,post.postMessage];
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
