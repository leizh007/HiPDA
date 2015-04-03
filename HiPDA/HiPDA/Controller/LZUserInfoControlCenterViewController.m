//
//  LZUserInfoControlCenterViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/23.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZUserInfoControlCenterViewController.h"
#import "LZNetworkHelper.h"
#import "LZAccount.h"
#import "LZUserInfoControlCenterView.h"
#import "LZUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LZShowMessagesHelper.h"


#define TAG_OVERVIEW 1000

@interface LZUserInfoControlCenterViewController()

@property (strong, nonatomic) LZUserInfoControlCenterView *lZUserInfoControlCenterView;
@property (strong, nonatomic) NSArray *fidList;
@property (strong, nonatomic) NSDictionary *fidDic;

@end

@implementation LZUserInfoControlCenterViewController{
    NSInteger selectIndex;
}

-(void)viewDidLoad{
    
}

-(id)init{
    self=[super init];
    if (self) {
        self.lZUserInfoControlCenterView=[[LZUserInfoControlCenterView alloc]initWithFrame:self.view.frame];
        self.view=self.lZUserInfoControlCenterView;
        self.lZUserInfoControlCenterView.tableView.delegate=self;
        self.lZUserInfoControlCenterView.tableView.dataSource=self;
        self.lZUserInfoControlCenterView.tableView.backgroundColor=[UIColor clearColor];
        [self.lZUserInfoControlCenterView.tableView setSeparatorColor:[UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1]];
        [self.lZUserInfoControlCenterView.tableView setSeparatorInset:UIEdgeInsetsZero];
        self.lZUserInfoControlCenterView.tableView.tableFooterView=[[UIView alloc]init];
        self.fidList=@[@"Discovery",@"Buy & Sell",@"E-INK",@"Geek Talks",@"疑似机器人"];
        self.fidDic=@{@"Discovery":[NSNumber numberWithInteger:DISCOVERYSECTIONFID],
                      @"Buy & Sell":[NSNumber numberWithInteger:BUYANDSELLSECTIONFID],
                      @"E-INK":[NSNumber numberWithInteger:EINKSECTIONFID],
                      @"Geek Talks":[NSNumber numberWithInteger:GEEKTALKSSECTIONFID],
                      @"疑似机器人":[NSNumber numberWithInteger:MACHINESECTIONFID]};
       
        NSIndexPath *selectedCellIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.lZUserInfoControlCenterView.tableView didSelectRowAtIndexPath:selectedCellIndexPath];
        [self.lZUserInfoControlCenterView.tableView selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        selectIndex=0;
        
        [self.lZUserInfoControlCenterView.myButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.lZUserInfoControlCenterView.msgButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.lZUserInfoControlCenterView.settingButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)loginComplete:(id)sender{
//    NSLog(@"登录成功！");
    NSArray *accountArray=[[LZAccount sharedAccount]getAccountInfo];
    self.lZUserInfoControlCenterView.userNameLabel.text=accountArray[0];
    LZUser *user=[[LZUser alloc] initWithAttributes:@{@"uid":[NSNumber numberWithInteger:[(NSString *)[[LZAccount sharedAccount] getAccountUid] integerValue]],
                                                      @"userName":[[LZAccount sharedAccount]getAccountInfo][0]}];
    self.lZUserInfoControlCenterView.userNameLabel.text=user.userName;
    [self.lZUserInfoControlCenterView.avatarImageView sd_setImageWithURL:user.avatarImageUrl];
}

-(void)viewDidAppear:(BOOL)animated{
//    NSLog(@"%lf %lf",self.view.frame.size.width,self.view.frame.size.height);
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fidList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellReusedIdentifier=@"cellReusedIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellReusedIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReusedIdentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=self.fidList[indexPath.row];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.row==selectIndex) {
        cell.backgroundColor=[UIColor colorWithRed:0.106 green:0.135 blue:0.162 alpha:1];
        cell.textLabel.textColor=[UIColor colorWithRed:0.999 green:1 blue:1 alpha:1];
    }else{
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor=[UIColor colorWithRed:0.581 green:0.6 blue:0.617 alpha:1];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectIndex=indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    [self.mainThreadViewController loadForumFid:[[self.fidDic objectForKey:self.fidList[indexPath.row]] integerValue] page:1 forced:NO];
    [self.revealViewController revealToggle:nil];
//    NSLog(@"%@ %ld",self.fidList[indexPath.row],[[self.fidDic objectForKey:self.fidList[indexPath.row]] integerValue]);
}

#pragma mark - SWRevealViewControllerDelegate
/**
 *  当rearview出现的时候禁止frontview的触控
 *
 *  @param revealController revealController
 *  @param position         当position为FrontViewPositionRight时才禁止
 */
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        UIView *lockingView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView setTag:1000];
        [revealController.frontViewController.view addSubview:lockingView];
    }
    else
        [[revealController.frontViewController.view viewWithTag:1000] removeFromSuperview];
}

#pragma mark - ButtonPressed

-(void)buttonPressed:(id)sender{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [sender setAlpha:0.1];
                     } completion:^(BOOL finished) {
                         [sender setAlpha:1.0];
                     }];
    [LZShowMessagesHelper showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"Sorry,还没实现呢！"];
}
@end
