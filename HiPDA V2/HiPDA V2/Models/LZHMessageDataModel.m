//
//  LZHMessageDataModel.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/17.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMessageDataModel.h"
#import "LZHHtmlParser.h"
#import "LZHUser.h"
#import "LZHHTTPRequestOperationManager.h"
#import "NSString+LZHHIPDA.h"

@implementation LZHMessageDataModel

-(id)init{
    self=[super init];
    if (self) {
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
        _messages=[[NSMutableArray alloc]init];
        _isMessageReadArray=[[NSMutableArray alloc]init];
    }
    return self;
}

+(void)getMessagesWithUser:(LZHUser *)user andDateRange:(NSInteger)dateRange completionHandler:(LZHNetworkFetcherCompletionHandler)completion{
    LZHHTTPRequestOperationManager *manager=[LZHHTTPRequestOperationManager sharedHTTPRequestOperationManager];
    NSString *URLString=[NSString stringWithFormat:@"http://www.hi-pda.com/forum/pm.php?uid=%@&daterange=%ld",user.uid,dateRange];
    [manager GET:URLString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *responseString=[NSString encodingGBKString:responseObject];
             [LZHHtmlParser extractMessagesFromHtmlString:responseString completionHandler:completion];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (completion) {
                 completion(nil,error);
             }
         }];
}

@end
