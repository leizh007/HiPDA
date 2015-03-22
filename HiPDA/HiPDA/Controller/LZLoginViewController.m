//
//  LZLoginViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/21.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZLoginViewController.h"
#import "LZLoginView.h"
#import "ActionSheetStringPicker.h"
#import "NSString+extension.h"
#import "SVProgressHUD.h"
#import "LZNetworkHelper.h"

@interface LZLoginViewController ()

@property (strong, nonatomic) LZLoginView  *loginView;
@property (strong, nonatomic) NSString     *userName;
@property (strong, nonatomic) NSString     *userPassword;
@property (strong, nonatomic) NSString     *safeQuestionNumber;
@property (strong, nonatomic) NSString     *safeQuestionAnswer;
@property (strong, nonatomic) NSArray      *safeQuestionArray;
@property (strong, nonatomic) NSDictionary *safeQuestionDic;

@end

@implementation LZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView=[[LZLoginView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view=self.loginView;
    [self.loginView.safeQuestionNumberButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.loginButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.safeQuestionArray=@[@"安全提问",@"母亲的名字",@"爷爷的名字",@"父亲出生的城市",@"您其中一位老师的名字",@"您个人计算机的型号",@"您最喜欢的餐馆名称",@"驾驶执照的最后四位数字"];
    self.safeQuestionDic=@{@"安全提问":@"0",@"母亲的名字":@"1",@"爷爷的名字":@"2",@"父亲出生的城市":@"3",@"您其中一位老师的名字":@"4",@"您个人计算机的型号":@"5",@"您最喜欢的餐馆名称":@"6",@"驾驶执照的最后四位数字":@"7"};
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

-(void)buttonPressed:(id)sender{
//    NSLog(@"%d button pressed!",(int)((UIButton *)sender).tag);
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.4];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:1.0];
                     }];
    NSInteger tag=((UIButton *)sender).tag;
    if (1==tag) {
        [ActionSheetStringPicker showPickerWithTitle:@"请选择安全提问"
                                                rows:self.safeQuestionArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               [self.loginView.safeQuestionNumberButton setTitle:self.safeQuestionArray[selectedIndex] forState:UIControlStateNormal];
                                               if (selectedIndex!=0) {
                                                   [self.loginView.safeQuestionNumberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                                               }else{
                                                   [self.loginView.safeQuestionNumberButton setTitleColor:[UIColor colorWithRed:0.66 green:0.782 blue:0.681 alpha:1] forState:UIControlStateNormal];
                                               }
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {

                                           }
                                              origin:self.view];
    }else if(2==tag){
        self.userName=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.userNameTextField.text];
        self.userPassword=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.userPassWoldTextField.text];
        self.safeQuestionNumber=self.safeQuestionDic[self.loginView.safeQuestionNumberButton.currentTitle];
        if ([self.safeQuestionNumber isEqualToString:@"0"]) {
            self.safeQuestionAnswer=@"";
        }else{
            self.safeQuestionAnswer=[NSString ifTheStringIsNilReturnAEmptyString:self.loginView.safeQuestionAnswerTextField.text];
        }
//        NSLog(@"username:%@\nuserpassword:%@\nsafequestion:%@\nanswer:%@\n",self.userName,self.userPassword,self.safeQuestionNumber,self.safeQuestionAnswer);
        [SVProgressHUD showWithStatus:@"奋力登录中..." maskType:SVProgressHUDMaskTypeGradient];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.0];
            dispatch_async(dispatch_get_main_queue(), ^{
                LZNetworkHelper *networkHelper=[LZNetworkHelper sharedLZNetworkHelper];
                [networkHelper getFormhash];
                [SVProgressHUD dismiss];
            });
        });
        
    }
}
@end
