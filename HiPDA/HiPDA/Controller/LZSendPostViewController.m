//
//  LZSendPostViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/4/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZSendPostViewController.h"
#import "ActionSheetStringPicker.h"
#import "LZNetworkHelper.h"
#import "SVProgressHUD.h"
#import "LZPost.h"


@interface LZSendPostViewController ()

@property (strong, nonatomic) LZSendPostView *sendPostView;
@property (strong, nonatomic) NSArray *classificationArray;

@end

@implementation LZSendPostViewController{
    NSInteger classificationSelectIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    classificationSelectIndex=0;
    self.sendPostView=[[LZSendPostView alloc]initWithFrame:self.view.frame];
    self.sendPostView.postType=self.postType;
    self.view=self.sendPostView;
    self.navigationItem.title=self.navTitle;
    [self.sendPostView.classificationButton addTarget:self action:@selector(classificationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.classificationArray=@[@"分类",@"聚会",@"汽车",@"大杂烩",@"助学",@"Discovery",@"投资",@"职场",@"文艺",@"版喃",@"显摆",@"晒物劝败",@"装修",@"YY",@"站务"];
    
    UIButton *cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:0.775 green:0.77 blue:1 alpha:0.1] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButtonItem=[[UIBarButtonItem alloc]initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem=cancelButtonItem;
    
    UIButton *sendButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:0.775 green:0.77 blue:1 alpha:0.1] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(sendPostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendButtonItem=[[UIBarButtonItem alloc]initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem=sendButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - classificationButtonPressed

-(void)classificationButtonPressed:(id)sender{
    [self.sendPostView.titleTextField resignFirstResponder];
    [self.sendPostView.contentTextView resignFirstResponder];
    [ActionSheetStringPicker showPickerWithTitle:@"请选择分类：" rows:self.classificationArray initialSelection:classificationSelectIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.sendPostView.classificationButton setTitle:self.classificationArray[selectedIndex] forState:UIControlStateNormal];
        classificationSelectIndex=selectedIndex;
        [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"虽然可选，发送时暂时还没加上这个功能！"];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.view];
}

#pragma mark - NavigationItem Button

-(void)cancelButtonPressed:(id)sender{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"真滴放弃编辑吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alert addAction:cancelAction];
    UIAlertAction *goOnAction=[UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alert addAction:goOnAction];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

-(void)sendPostButtonPressed:(id)sendere{
    [self.sendPostView.titleTextField resignFirstResponder];
    [self.sendPostView.contentTextView resignFirstResponder];
    if (self.postType==POSTTYPENEWTHREAD) {
        if ([self.sendPostView.titleTextField.text length]==0) {
            [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"标题不能为空！"];
        }else if([self.sendPostView.contentTextView.text length]==0){
            [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"内容不能为空！"];
        }
    }
    [SVProgressHUD showWithStatus:@"正在发表"];
    [[LZNetworkHelper sharedLZNetworkHelper] sendPostWithTitle:self.sendPostView.titleTextField.text
                                                       content:self.sendPostView.contentTextView.text
                                                           fid:self.fid
                                                           tid:self.tid==nil?@"":self.tid
                                                          post:self.post
                                                    threadType:0
                                                        images:[[NSArray alloc]init]
                                                  quoteContent:@""
                                                      postType:self.postType
                                                         block:^(BOOL isSuccess, NSError *error) {
         if (isSuccess) {
             [self dismissViewControllerAnimated:YES completion:nil];
             [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"发表成功"];
         }else{
             [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
         }
     }
                                                         ];
}

@end
