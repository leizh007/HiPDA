//
//  LZHMessageDataModel.h
//  HiPDA V2
//
//  Created by leizh007 on 15/5/17.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"
#import "LZHNetworkFetcher.h"

@class LZHUser;

@interface LZHMessageDataModel : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;

@property (strong, nonatomic) NSMutableArray *isMessageReadArray;

/**
 *  得到消息列表
 *
 *  @param user       用户
 *  @param dateRange  dateRange
 *  @param completion 0:formhash 1:handlekey 2:lastdaterange 3:daterange 4:messages
 */
+(void)getMessagesWithUser:(LZHUser *)user andDateRange:(NSInteger)dateRange completionHandler:(LZHNetworkFetcherCompletionHandler)completion;


@end
