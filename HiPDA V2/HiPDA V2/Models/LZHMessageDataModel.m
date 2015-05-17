//
//  LZHMessageDataModel.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/17.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMessageDataModel.h"

@implementation LZHMessageDataModel

-(instancetype)init{
    self=[super init];
    if (!self) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self;
}

@end
