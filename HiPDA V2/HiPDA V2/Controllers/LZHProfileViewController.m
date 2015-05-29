//
//  LZHProfileViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/6.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHProfileViewController.h"
#import "LZHUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+LZHHIPDA.h"
#import "LZHAccount.h"
#import "LZHBlackList.h"
#import "MZFormSheetController.h"
#import "LZHSendPmViewController.h"
#import "LZHCustomeTransition.h"
#import "LZHReply.h"
#import "LZHShowMessage.h"
#import "SVProgressHUD.h"
#import "LZHSearchViewController.h"

#define LZHProfileDefaultFontColor [UIColor colorWithRed:0.265 green:0.265 blue:0.265 alpha:1]
#define LZHProfileUserNameFontColor [UIColor colorWithRed:1 green:0.622 blue:0 alpha:1]
#define LZHProfileButtonBackgroundColor [UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1]
#define LZHProfileButtonHighlightedBackgroundColor [UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:0.2]
#define LZHProfileButtonHighlightedTitleColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

const CGFloat LZHProfileAvatarImageViewSize=70.0f;
const CGFloat LZHProfileDistanceBetweenViews=8.0f;
const CGFloat LZHProfileButtonHeight=40.0f;

@interface LZHProfileViewController ()<LZHSendPmViewControllDelegate>

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong ,nonatomic) UILabel *uidLabel;
@property (strong ,nonatomic) UIButton *sendPmButton;
@property (strong, nonatomic) UIButton *addFriendButton;
@property (strong, nonatomic) UIButton *searchThreadsButton;
@property (strong, nonatomic) UIButton *blackListButton;
@property (assign, nonatomic) BOOL isUserInBlackList;
@property (strong, nonatomic) LZHSendPmViewController *sendPmViewController;
@property (copy, nonatomic) NSString *pmMessage;

@end

@implementation LZHProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    [MZFormSheetController registerTransitionClass:[LZHCustomeTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];
    
    NSDictionary *accountInfo=[[LZHAccount sharedAccount] account];
    NSString *accountUserName=accountInfo[LZHACCOUNTUSERNAME];
    
    self.navigationItem.title=@"用户信息";
    _pmMessage=@"";
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.user=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:self.user.uid,
                                                   LZHUSERUSERNAME:self.user.userName}];
    
    _avatarImageView=[[UIImageView alloc]initWithFrame:CGRectMake(LZHProfileDistanceBetweenViews, 64+LZHProfileDistanceBetweenViews, LZHProfileAvatarImageViewSize,LZHProfileAvatarImageViewSize)];
    _avatarImageView.layer.cornerRadius=15.0f;
    _avatarImageView.layer.borderWidth=1.0f;
    _avatarImageView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    _avatarImageView.clipsToBounds=YES;
    
    __weak typeof(self) weakSelf=self;
    SDWebImageManager *manager=[SDWebImageManager sharedManager];
    [manager downloadImageWithURL:_user.avatarImageURL
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (error) {
                                weakSelf.avatarImageView.image=[UIImage imageNamed:@"avatar"];
                            }else{
                                weakSelf.avatarImageView.image=image;
                            }
                        }];
    [self.view addSubview:_avatarImageView];
    
    _userNameLabel=[[UILabel alloc]init];
    NSMutableAttributedString *attributedString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"用户名：%@",_user.userName]];
    NSDictionary *attributes1=@{NSForegroundColorAttributeName:LZHProfileUserNameFontColor};
    [attributedString addAttributes:attributes1 range:NSMakeRange(4, _user.userName.length)];
    NSDictionary *attributes2=@{NSForegroundColorAttributeName:LZHProfileDefaultFontColor};
    [attributedString addAttributes:attributes2 range:NSMakeRange(0, 4)];
    _userNameLabel.attributedText=attributedString;
    
    [_userNameLabel sizeToFit];
    
    _uidLabel=[[UILabel alloc]init];
    _uidLabel.text=[NSString stringWithFormat:@"    UID：%@",_user.uid];
    _uidLabel.textColor=LZHProfileDefaultFontColor;
    [_uidLabel sizeToFit];
    _uidLabel.frame=CGRectMake(3+LZHProfileAvatarImageViewSize+2*LZHProfileDistanceBetweenViews, _avatarImageView.frame.origin.y+LZHProfileAvatarImageViewSize-_uidLabel.frame.size.height, _uidLabel.frame.size.width, _uidLabel.frame.size.height);
    [self.view addSubview:_uidLabel];
    
    _userNameLabel.frame=CGRectMake(LZHProfileAvatarImageViewSize+2*LZHProfileDistanceBetweenViews, _avatarImageView.frame.origin.y+LZHProfileAvatarImageViewSize-_uidLabel.frame.size.height*2-LZHProfileDistanceBetweenViews, _userNameLabel.frame.size.width, _userNameLabel.frame.size.height);
    [self.view addSubview:_userNameLabel];
    
    
    _sendPmButton=[[UIButton alloc]initWithFrame:CGRectMake(LZHProfileDistanceBetweenViews, _avatarImageView.frame.origin.y+LZHProfileAvatarImageViewSize+LZHProfileDistanceBetweenViews*3, [[UIScreen mainScreen]bounds].size.width-2*LZHProfileDistanceBetweenViews, LZHProfileButtonHeight)];
    [_sendPmButton setTitle:@"发短消息" forState:UIControlStateNormal];
    
    
    
    
    _addFriendButton=[[UIButton alloc]initWithFrame:CGRectMake(LZHProfileDistanceBetweenViews, _sendPmButton.frame.origin.y+LZHProfileButtonHeight+LZHProfileDistanceBetweenViews, _sendPmButton.frame.size.width, LZHProfileButtonHeight)];
    [_addFriendButton setTitle:@"加为好友" forState:UIControlStateNormal];
    
    
    
    
    _searchThreadsButton=[[UIButton alloc]initWithFrame:CGRectMake(LZHProfileDistanceBetweenViews, _addFriendButton.frame.origin.y+LZHProfileButtonHeight+LZHProfileDistanceBetweenViews, _addFriendButton.frame.size.width, LZHProfileButtonHeight)];
    [_searchThreadsButton setTitle:@"搜索帖子" forState:UIControlStateNormal];
    [self setPropertiesOfButton:_searchThreadsButton isEnable:YES];
    [_searchThreadsButton addTarget:self action:@selector(searchThreadsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _blackListButton=[[UIButton alloc]initWithFrame:CGRectMake(LZHProfileDistanceBetweenViews, _searchThreadsButton.frame.origin.y+LZHProfileDistanceBetweenViews+LZHProfileButtonHeight, _searchThreadsButton.frame.size.width, LZHProfileButtonHeight)];
    [_blackListButton setTitle:@"加入黑名单" forState:UIControlStateNormal];
    
    BOOL isEnable=YES;
    if ([_user.userName isEqualToString:accountUserName]) {
        isEnable=NO;
    }else{
        [_blackListButton addTarget:self action:@selector(blackListButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_addFriendButton addTarget:self action:@selector(addFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_sendPmButton addTarget:self action:@selector(sendPmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setPropertiesOfButton:_sendPmButton isEnable:isEnable];
    [self setPropertiesOfButton:_addFriendButton isEnable:isEnable];
    [self setPropertiesOfButton:_blackListButton isEnable:isEnable];
    
    [self.view addSubview:_sendPmButton];
    [self.view addSubview:_addFriendButton];
    [self.view addSubview:_searchThreadsButton];
    [self.view addSubview:_blackListButton];
    
    self.isUserInBlackList=[[LZHBlackList sharedBlackList] isUserNameInBlackList:_user.userName];
}

-(void)setPropertiesOfButton:(UIButton *)button isEnable:(BOOL)enable{
    if (enable) {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:LZHProfileButtonHighlightedTitleColor forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageWithColor:LZHProfileButtonBackgroundColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:LZHProfileButtonHighlightedBackgroundColor] forState:UIControlStateHighlighted];
    }else{
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setBackgroundColor:LZHProfileButtonBackgroundColor];
    }
    button.layer.cornerRadius=7.0f;
    button.clipsToBounds=YES;
    button.layer.borderWidth=1.0f;
    button.layer.borderColor=[[UIColor lightGrayColor] CGColor];
}

-(void)setIsUserInBlackList:(BOOL)isUserInBlackList{
    _isUserInBlackList=isUserInBlackList;
    if (isUserInBlackList) {
        [_blackListButton setTitle:@"移出黑名单" forState:UIControlStateNormal];
    }else{
        [_blackListButton setTitle:@"加入黑名单" forState:UIControlStateNormal];
    }
}

#pragma mark - Button Pressed

-(void)sendPmButtonPressed:(id)sender{
    _sendPmViewController=[[LZHSendPmViewController alloc]init];
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:_sendPmViewController];
    _sendPmViewController.navigationItem.title=[NSString stringWithFormat:@"To:%@",_user.userName];
    _sendPmViewController.message=_pmMessage;
    _sendPmViewController.delegate=self;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:navigationController];
    
    formSheet.presentedFormSheetSize = CGSizeMake(300, 240);
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsMoveAboveKeyboard;
    formSheet.formSheetWindow.transparentTouchEnabled = NO;
    formSheet.transitionStyle = MZFormSheetTransitionStyleCustom;

    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
    
}

-(void)addFriendButtonPressed:(id)sender{
    [SVProgressHUD showWithStatus:@"正在发送请求..." maskType:SVProgressHUDMaskTypeGradient];
    [LZHReply addFriend:_user completionHandler:^(NSArray *array, NSError *error) {
        if (error) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:array[0]];
        }
    }];
}


-(void)searchThreadsButtonPressed:(id)sender{
    LZHSearchViewController *searchViewController=[[LZHSearchViewController alloc]init];
    searchViewController.user=_user;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

-(void)blackListButtonPressed:(id)sender{
    LZHBlackList *blackList=[LZHBlackList sharedBlackList];
    
    if (_isUserInBlackList) {
        [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"已将该用户移出黑名单！"];
        [blackList removeUserNameFromBlackList:_user.userName];
        self.isUserInBlackList=NO;
    }else{
        [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"已将该用户残忍加入黑名单！"];
        [blackList addUserNameToBlackList:_user.userName];
        self.isUserInBlackList=YES;
    }
}

#pragma mark - status bar
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - LZHSendPmViewControllDelegate
-(void)didFinishEdittingMessage:(NSString *)message isSend:(BOOL)send{
    _pmMessage=message;
    if (send&&![message isEqualToString:@""]) {
        [SVProgressHUD showWithStatus:@"正在发送请求..." maskType:SVProgressHUDMaskTypeGradient];
        [LZHReply sendPmToUser:_user
                       message:message
             completionHandler:^(NSArray *array, NSError *error) {
                 if (error) {
                     [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                 }else{
                     [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:array[0]];
                 }
             }];
    }
}

@end
