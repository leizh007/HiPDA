//
//  LZViewThreadDetailViewController.m
//  HiPDA
//
//  Created by leizh007 on 15/3/30.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZViewThreadDetailViewController.h"
#import "SWRevealViewController.h"
#import "LZNetworkHelper.h"
#import "LZThreadDetail.h"

@interface LZViewThreadDetailViewController ()

@property (assign, nonatomic) NSInteger page;

@end

@implementation LZViewThreadDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor greenColor];
    self.page=1;
//    self.navigationItem.title=self.threadTitle;
//    NSLog(@"%@",self.tid);
    [[LZNetworkHelper sharedLZNetworkHelper] loadPostListTid:self.tid page:self.page isNeedPageFullNumber:YES success:^(NSDictionary *postThreadInfo) {
        NSArray *threadDetailList=[postThreadInfo objectForKey:@"threadlist"];
        for (LZThreadDetail *threadDetail in threadDetailList) {
            NSLog(@"postnum--->%ld",threadDetail.postnum);
            for (NSDictionary *dic in threadDetail.contextArray) {
                if ([dic objectForKey:THREADLISTDETAILIMAGE]!=nil) {
                    NSLog(@"%@",[dic objectForKey:THREADLISTDETAILIMAGE]);
                }
                if ([dic objectForKey:THREADLISTDETAILSTRING]!=nil) {
                    NSLog(@"%@",[dic objectForKey:THREADLISTDETAILSTRING]);
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    /**
     *  移除SWRevealViewController的手势操作
     */
    SWRevealViewController *revealViewController=[self revealViewController];
    revealViewController.panGestureRecognizer.enabled=NO;
    revealViewController.tapGestureRecognizer.enabled=NO;
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

@end
