//
//  LZHMessagesViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/5/17.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHMessagesViewController.h"
#import "LZHMessageDataModel.h"
#import "LZHUser.h"
#import "LZHAccount.h"
#import "SVProgressHUD.h"
#import "LZHShowMessage.h"
#import "LZHProfileViewController.h"
#import "LZHReply.h"

@interface LZHMessagesViewController ()

@property (strong, nonatomic) LZHMessageDataModel *messageData;
@property (copy, nonatomic) NSString *formhash;
@property (copy, nonatomic) NSString *handleKey;
@property (copy, nonatomic) NSString *lastDateRange;
@property (strong, nonatomic) JSQMessagesAvatarImage *myAvatarImage;
@property (strong, nonatomic) JSQMessagesAvatarImage *friendAvatarImage;
@property (strong, nonatomic) LZHUser *mySelf;

@end

@implementation LZHMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:_myAvatar
                                                              diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    _friendAvatarImage=[JSQMessagesAvatarImageFactory avatarImageWithImage:_friendAvatar
                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    _messageData=[[LZHMessageDataModel alloc]init];
    NSDictionary *accountInfo=[[LZHAccount sharedAccount] account];
    _messageData.users=@{_friend.userName:_friend.userName,
                         accountInfo[LZHACCOUNTUSERNAME]:accountInfo[LZHACCOUNTUSERNAME]};
    _mySelf=[[LZHUser alloc]initWithAttributes:@{LZHUSERUID:accountInfo[LZHACCOUNTUSERUID],
                                                 LZHUSERUSERNAME:accountInfo[LZHACCOUNTUSERNAME]}];
    
    self.title=_friend.userName;
    
    
    self.senderId=[accountInfo objectForKey:LZHACCOUNTUSERNAME];
    self.senderDisplayName=[accountInfo objectForKey:LZHACCOUNTUSERNAME];
    
    self.showLoadEarlierMessagesHeader=NO;
    
    self.inputToolbar.contentView.leftBarButtonItem=nil;
    
    [self loadNewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据相关

-(void)loadNewData{
    [SVProgressHUD showWithStatus:@"正在获取对话列表..." maskType:SVProgressHUDMaskTypeGradient];
    [LZHMessageDataModel getMessagesWithUser:_friend andDateRange:_dateRange completionHandler:^(NSArray *array, NSError *error) {
        if (error!=nil) {
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
        }else{
            [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPESUCCESS message:@"获取列表成功！"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                
                NSDictionary *parameters=array[0];
                self.formhash=parameters[@"formhash"];
                self.handleKey=parameters[@"handlekey"];
                self.lastDateRange=parameters[@"lastdaterange"];
                self.messageData.isMessageReadArray=array[1];
                self.messageData.messages=array[2];
                
                [self finishReceivingMessageAnimated:YES];
            });
        }
    }];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [_messageData.messages addObject:message];
    [_messageData.isMessageReadArray addObject:@NO];
    
    [self finishSendingMessageAnimated:YES];
    
    NSInteger messageIndex=_messageData.messages.count;
    [LZHReply replyPrivatePmToUser:_friend
                      withFormhash:_formhash
                         handlekey:_handleKey
                     lastdaterange:_lastDateRange
                           message:text
                 completionHandler:^(NSArray *array, NSError *error) {
                     if (error) {
                         [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
                         [_messageData.messages removeObjectAtIndex:messageIndex];
                     }
                 }];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messageData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.messageData.outgoingBubbleImageData;
    }
    
    return self.messageData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return _myAvatarImage;
    }
    else {
        return _friendAvatarImage;
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messageData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.messageData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
            if (![_messageData.isMessageReadArray[indexPath.row] boolValue]) {
                cell.textView.textColor=[UIColor redColor];
            }
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
            if (![_messageData.isMessageReadArray[indexPath.row]boolValue]) {
                cell.textView.textColor=[UIColor redColor];
            }
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message=_messageData.messages[indexPath.row];
    LZHProfileViewController *profileViewController=[[LZHProfileViewController alloc]init];
    if ([message.senderId isEqualToString:self.senderId]) {
        profileViewController.user=_mySelf;
    }else{
        profileViewController.user=_friend;
    }
    [self.navigationController pushViewController:profileViewController animated:YES];
}


@end
