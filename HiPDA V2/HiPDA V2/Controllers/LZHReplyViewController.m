//
//  LZHReplyViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/6/3.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHReplyViewController.h"
#import "SZTextView.h"
#import "LZHKeyboardBuilder.h"
#import "ActionSheetPicker.h"
#import "MTLog.h"

static const CGFloat kTitleTextFieldLeftPadding=8.0f;

const NSString *LZHReplyDiscoveryFid=@"2";
const NSString *LZHReplyBuyAndSellFid=@"6";
const NSString *LZHReplyEInkFid=@"59";
const NSString *LZHReplyGeekTalksFid=@"7";
const NSString *LZHReplyMachineFid=@"57";

@interface LZHReplyViewController ()

@property (strong, nonatomic) NSDictionary *typeIdArrayForFidDictionary;
@property (strong, nonatomic) NSDictionary *typeId;
@property (strong, nonatomic) UIButton *typeIdButton;
@property (strong, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) SZTextView *contentTextView;
@property (assign, nonatomic) CGFloat contentTextViewFrameOriginY;

@end

@implementation LZHReplyViewController{
    NSInteger typeIdSelectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化参数
    typeIdSelectedIndex=0;
    
    _typeIdArrayForFidDictionary=@{LZHReplyDiscoveryFid:@[@"分类",@"聚会",@"汽车",@"大杂烩",@"助学",@"Discovery",@"投资",@"职场",@"文艺",@"版喃",@"显摆",@"晒物劝败",@"装修",@"YY",@"站务"],LZHReplyBuyAndSellFid:@[@"分类",@"手机",@"掌上电脑",@"笔记本电脑",@"无线产品",@"数码相机、摄像机",@"MP3随身听",@"各类配件",@"其他好玩的",@"站务"],LZHReplyEInkFid:@[@"分类",@"Kindle",@"SONY",@"国产",@"资源",@"综合",@"交流",@"Nook",@"Kobo",@"求助",@"站务"],LZHReplyGeekTalksFid:@[@"分类",@"Gadgets",@"无线",@"嵌入式Linux",@"业界",@"安卓",@"高清播放器",@"站务"],LZHReplyMachineFid:@[@"分类"]};
    _typeId=@{@"分类":@"0",@"聚会":@"9",@"汽车":@"33",@"大杂烩":@"38",@"助学":@"40",@"Discovery":@"56",@"投资":@"57",@"职场":@"58",@"文艺":@"65",@"版喃":@"66",@"显摆":@"67",@"晒物劝败":@"79",@"装修":@"81",@"YY":@"39",@"站务":@"19",@"手机":@"1",@"掌上电脑":@"2",@"笔记本电脑":@"3",@"无线产品":@"4",@"数码相机、摄像机":@"5",@"MP3随身听":@"6",@"各类配件":@"7",@"其他好玩的":@"8",@"Kindle":@"68",@"SNOY":@"69",@"国产":@"70",@"资源":@"72",@"综合":@"73",@"交流":@"75",@"Nook":@"77",@"Kobo":@"80",@"求助":@"18",@"Gadgets":@"20",@"无线":@"21",@"嵌入式Linux":@"22",@"业界":@"41",@"安卓":@"74",@"高清播放器":@"76"};
    
    [self arrangeViews];
}

#pragma mark - View

-(void)arrangeViews {
    self.view.backgroundColor=[UIColor whiteColor];
    switch (self.replyType) {
        case LZHReplyTypeNewTopic: {
            self.title=@"发表新帖";
            break;
        }
        case LZHreplyTypeNewPost: {
            self.title=@"发表回复";
            break;
        }
        case LZHReplyTypeReply: {
            self.title=[NSString stringWithFormat:@"回复#%@",_pid];
            break;
        }
        case LZHReplyTypeQuote: {
            self.title=[NSString stringWithFormat:@"引用#%@",_pid];
            break;
        }
    }
    
    UIBarButtonItem *cancelBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem=cancelBarButtonItem;
    
    UIBarButtonItem *sendBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
    self.navigationItem.rightBarButtonItem=sendBarButtonItem;
    
    if (self.replyType==LZHReplyTypeNewTopic) {
        _typeIdButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 64, 80, 35)];
        _typeIdButton.backgroundColor=[UIColor whiteColor];
        [_typeIdButton addTarget:self action:@selector(typeIdButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_typeIdButton setTitle:@"分类" forState:UIControlStateNormal];
        [_typeIdButton setTitleColor:[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1] forState:UIControlStateNormal];
        [_typeIdButton setTitleColor:[UIColor colorWithRed:0 green:0.459 blue:1 alpha:0.2] forState:UIControlStateHighlighted];
        [_typeIdButton setTitleColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1] forState:UIControlStateDisabled];
        if ([_typeIdArrayForFidDictionary[_fid] count]==1) {
            _typeIdButton.enabled=NO;
        }
        
        [self.view addSubview:_typeIdButton];
        UILabel *seperatorDownLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _typeIdButton.frame.origin.y+_typeIdButton.frame.size.height, [[UIScreen mainScreen]bounds].size.width, 1.0f)];
        seperatorDownLabel.backgroundColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1];
        [self.view addSubview:seperatorDownLabel];
        _contentTextViewFrameOriginY=seperatorDownLabel.frame.origin.y+1.0f;
        UILabel *seperatorRightLabel=[[UILabel alloc]initWithFrame:CGRectMake(_typeIdButton.frame.origin.x+_typeIdButton.frame.size.width, _typeIdButton.frame.origin.y, 1.0f, _typeIdButton.frame.size.height)];
        seperatorRightLabel.backgroundColor=[UIColor colorWithRed:0 green:0.459 blue:1 alpha:1];
        [self.view addSubview:seperatorRightLabel];
        
        _titleTextField=[[UITextField alloc]initWithFrame:CGRectMake(seperatorRightLabel.frame.origin.x+1.0f+kTitleTextFieldLeftPadding, _typeIdButton.frame.origin.y, [[UIScreen mainScreen]bounds].size.width-seperatorRightLabel.frame.origin.x-1.0f-kTitleTextFieldLeftPadding, _typeIdButton.frame.size.height)];
        _titleTextField.placeholder=@"title here...";
        
        [self.view addSubview:_titleTextField];
    }else{
        _contentTextViewFrameOriginY=0.0f;
    }
    
    _contentTextView=[[SZTextView alloc]initWithFrame:CGRectMake(0, _contentTextViewFrameOriginY, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-_contentTextViewFrameOriginY)];
    _contentTextView.placeholder=@"content here...";
    _contentTextView.font=[UIFont systemFontOfSize:17.0f];
    [self.view addSubview:_contentTextView];
}

#pragma mark - Button Pressed

-(void)cancelButtonPressed:(UIButton *)button {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf=self;
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"放弃" message:@"是否真的放弃编辑？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)sendButtonPressed:(UIButton *)button{
    [self switchKeyBoard:button];
    
    //NSLog(@"typeid:%@",_typeId[_typeIdButton.currentTitle]);
}

-(void)typeIdButtonPressed:(UIButton *)button{
    [self.view endEditing:YES];
    [ActionSheetStringPicker showPickerWithTitle:@"请选择类别：" rows:_typeIdArrayForFidDictionary[_fid] initialSelection:typeIdSelectedIndex doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        typeIdSelectedIndex=selectedIndex;
        [_typeIdButton setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.view];
}

-(void)switchKeyBoard:(UIButton *)button{
    if (_contentTextView.isFirstResponder) {
        if (_contentTextView.emoticonsKeyboard) {
            [_contentTextView switchToDefaultKeyboard];
        }else{
            [_contentTextView switchToEmoticonsKeyboard:[LZHKeyboardBuilder sharedEmoticonsKeyboard]];
        }
    }else if(!_titleTextField.isFirstResponder){
        [_contentTextView becomeFirstResponder];
    }
}

//- (IBAction)switchKeyboard:(UIButton *)sender {
//    if (self.textView.isFirstResponder) {
//        if (self.textView.emoticonsKeyboard) [self.textView switchToDefaultKeyboard];
//        else [self.textView switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
//    }else{
//        [self.textView switchToEmoticonsKeyboard:[WUDemoKeyboardBuilder sharedEmoticonsKeyboard]];
//        [self.textView becomeFirstResponder];
//    }
//}
@end
