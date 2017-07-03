//
//  ChatViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/3.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import RxSwift
import RxCocoa

class ChatViewController: JSQMessagesViewController {
    var user: User! {
        didSet {
            viewModel = ChatViewModel(user: user)
        }
    }
    private let disposeBag = DisposeBag()
    fileprivate var viewModel: ChatViewModel!
    fileprivate var incomingBubble: JSQMessagesBubbleImage!
    fileprivate var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var isDataLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.name
        senderId = "\(Settings.shared.activeAccount?.uid ?? 0)"
        senderDisplayName = Settings.shared.activeAccount?.name ?? ""
        configureApperance()
        configureInputToolbar(inputToolbar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isDataLoaded {
            // 放在viewDidLoad里面cell的布局有问题（这个库有bug）
            fetchConversation()
        }
    }
    
    private func configureApperance() {
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: .jsq_messageBubbleGreen())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: .jsq_messageBubbleLightGray())
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault,
                                                                            height: kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault,
                                                                            height: kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    private func configureInputToolbar(_ inputToolbar: JSQMessagesInputToolbar) {
        inputToolbar.contentView.leftBarButtonItemWidth = 0.0
        inputToolbar.contentView.leftBarButtonItem = nil
    }
    
    private func fetchConversation() {
        showTypingIndicator = !showTypingIndicator
        viewModel.fetchConversation { [weak self] result in
            if case .failure(let error) = result {
                self?.showPromptInformation(of: .failure(error.localizedDescription))
            }
            self?.finishReceivingMessage(animated: true)
            self?.collectionView.reloadData()
            self?.isDataLoaded = true
        }
    }
}

// MARK: - JSQMessagesCollectionViewDataSource

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return viewModel.message(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let messageCell = cell as? JSQMessagesCollectionViewCell {
            switch viewModel.messageType(at: indexPath.row) {
            case .incoming:
                messageCell.textView.textColor = .white
            case .outgoing:
                messageCell.textView.textColor = .black
            }
            messageCell.textView.linkTextAttributes = [
                NSForegroundColorAttributeName: messageCell.textView.textColor ?? .white,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.patternSolid.rawValue
            ]
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        switch viewModel.messageType(at: indexPath.row) {
        case .incoming:
            return incomingBubble
        case .outgoing:
            return outgoingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return viewModel.avatar(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if !viewModel.shouldShowCellTopLabel(at: indexPath.row) {
            return nil
        }
        let attri = NSMutableAttributedString(string: viewModel.dateString(at: indexPath.row))
        return attri
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return viewModel.shouldShowCellTopLabel(at: indexPath.row) ? 30.0 : 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let user = viewModel.user(at: indexPath.row)
        let vc = UserProfileViewController.load(from: .home)
        vc.uid = user.uid
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text) else { return }
        viewModel.sendMessage(message) { [weak self] result in
            if case .failure(let error) = result {
                self?.showPromptInformation(of: .failure(error.localizedDescription))
                self?.collectionView.reloadData()
            }
        }
        
        finishSendingMessage(animated: true)
    }
}
