//
//  LZHLoginViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/4/25.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHLoginViewController.h"
#import "NSString+LZHHIPDA.h"
#import "LZHNetworkFetcher.h"
#import "SVProgressHUD.h"
#import "LZHShowMessage.h"
#import "LZHAccount.h"

@interface LZHLoginViewController ()

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *section;
@property (strong, nonatomic) RETextItem *userName;
@property (strong, nonatomic) RETextItem *password;
@property (strong, nonatomic) REPickerItem *questionId;
@property (strong, nonatomic) RETextItem *questionAnswer;
@property (strong, nonatomic) RETableViewItem *loginButton;
@property (strong, nonatomic) NSDictionary *questionIdDic;
@property (strong, nonatomic) NSArray *questionIdArray;

@end

@implementation LZHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"论坛登录";
    _questionIdDic=@{@"安全提问":@"0",
                     @"母亲的名字":@"1",
                     @"爷爷的名字":@"2",
                     @"父亲出生的城市":@"3",
                     @"您其中一位老师的名字":@"4",
                     @"您个人计算机的型号":@"5",
                     @"您最喜欢的餐馆名称":@"6",
                     @"驾驶执照的最后四位数字":@"7"};
    _questionIdArray=@[@"安全提问",
                       @"母亲的名字",
                       @"爷爷的名字",
                       @"父亲出生的城市",
                       @"您其中一位老师的名字",
                       @"您个人计算机的型号",
                       @"您最喜欢的餐馆名称",
                       @"驾驶执照的最后四位数字"];
    _manager=[[RETableViewManager alloc]initWithTableView:self.tableView delegate:self];
    _section=[RETableViewSection section];
    [_manager addSection:_section];
    _userName=[RETextItem itemWithTitle:@"用户名" value:@"" placeholder:@"请输入用户名"];
    _password=[RETextItem itemWithTitle:@"密码" value:@"" placeholder:@"请输入密码"];
    _password.secureTextEntry=YES;
    _questionId=[REPickerItem itemWithTitle:@"安全提问" value:@[_questionIdArray[0]] placeholder:nil options:@[_questionIdArray]];
    _questionAnswer=[RETextItem itemWithTitle:@"回答" value:@"" placeholder:@"请输入答案"];
    
    __weak typeof(self) weakSelf=self;
    _loginButton=[RETableViewItem itemWithTitle:@"登录" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [weakSelf login];
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
    }];
    _loginButton.textAlignment=NSTextAlignmentCenter;
    [_section addItem:_userName];
    [_section addItem:_password];
    [_section addItem:_questionId];
    [_section addItem:_questionAnswer];
    [_section addItem:_loginButton];
}

-(void)login{
    NSString *userName=_userName.value;
    NSString *password=[_password.value md5];
    NSString *questionId=_questionIdDic[_questionId.value[0]];
    NSString *questionAnswer=_questionAnswer.value;
    [SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeGradient];
    [LZHNetworkFetcher loginWithUserName:userName password:password questionId:questionId questionAnswer:questionAnswer completionHandler:^(NSArray *array, NSError *error) {
        if (error==nil) {
            //咱是保存用户信息，uid和用户头像待获取
            [[LZHAccount sharedAccount] setAccount:@{LZHACCOUNTUSERNAME:userName,
                                                     LZHACCOUNTUSERPASSWORDD:password,
                                                     LZHACCOUNTQUESTIONID:questionId,
                                                     LZHACCOUNTQUESTIONANSWER:questionAnswer
                                                     }];
            [LZHNetworkFetcher getUidAndAvatarThenSaveUserName:userName password:password questionId:questionId questionAnswer:questionAnswer];
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"登录成功!"];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }
    }];
}

@end
