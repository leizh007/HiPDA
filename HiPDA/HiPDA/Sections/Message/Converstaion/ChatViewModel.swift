//
//  ChatViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/3.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import RxSwift
import SDWebImage

enum ChatMessageType {
    case incoming
    case outgoing
}

class ChatViewModel {
    let user: User
    fileprivate var disposeBag = DisposeBag()
    fileprivate var messages = [JSQMessage]()
    fileprivate var avatars = [String: JSQMessagesAvatarImage]()
    fileprivate var formhash = ""
    fileprivate var lastdaterange = ""
    fileprivate let dateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-M-d"
        return dateFormater
    }()
    fileprivate let secondDateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-M-d HH:mm:ss"
        return dateFormater
    }()
    init(user: User) {
        self.user = user
    }
    
    func fetchConversation(with completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        guard let account = Settings.shared.activeAccount else {
            completion(.failure(NSError(domain: "HiPDA", code: -1, userInfo: [NSLocalizedDescriptionKey: "请登录后再使用"])))
            return
        }
        let group = DispatchGroup()
        for user in [self.user, User(name: account.name, uid: account.uid)] {
            group.enter()
            ChatViewModel.getAvatar(of: user) { image  in
                self.avatars["\(user.uid)"] = JSQMessagesAvatarImageFactory.avatarImage(withPlaceholder: image, diameter: UInt(max(image.size.width, image.size.height) / C.UI.screenScale))
                group.leave()
            }
        }
        var event: (Event<[JSQMessage]>)!
        group.enter()
        disposeBag = DisposeBag()
        HiPDAProvider.request(.privateMessageConversation(uid: user.uid))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .do(onNext: { [weak self] html in
                self?.formhash = try HtmlParser.replyValue(for: "formhash", in: html)
                self?.lastdaterange = try HtmlParser.replyValue(for: "lastdaterange", in: html)
            })
            .map { try HtmlParser.chatMessges(from: $0).map(self.transform(message:)) }
            .observeOn(MainScheduler.instance)
            .subscribe { e in
                switch e {
                case .next(_):
                    fallthrough
                case .error(_):
                    event = e
                    group.leave()
                default:
                    break
                }
            }.disposed(by: disposeBag)
        group.notify(queue: DispatchQueue.main) {
            switch event! {
            case .next(let messages):
                self.messages = messages
                completion(.success(()))
            case .error(let error):
                completion(.failure(error as NSError))
            default:
                break
            }
        }
    }
    
    private static func getAvatar(of user: User, completion: @escaping (UIImage) -> Void) {
        SDWebImageManager.shared().loadImage(with: user.avatarImageURL, options: [], progress: nil) { (image, _, _, _, _, _) in
            if let image = image {
                completion(image)
            } else {
                completion(#imageLiteral(resourceName: "avatar_placeholder"))
            }
        }
    }
    
    private func transform(message: ChatMessage) -> JSQMessage {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-M-d HH:mm"
        let date = dateFormater.date(from: message.time) ?? Date()
        let senderId = message.name == user.name ? user.uid : (Settings.shared.activeAccount?.uid ?? 0)
        return JSQMessage(senderId: "\(senderId)", senderDisplayName: message.name, date: date, text: message.content)
    }
    
    fileprivate func dateString(of date: Date) -> String {
        return dateFormater.string(from: date)
    }
    
    func sendMessage(_ message: JSQMessage, with completion: @escaping (HiPDA.Result<Void, NSError>) -> Void) {
        messages.append(message)
        HiPDAProvider.request(.replypm(uid: user.uid, formhash: formhash, lastdaterange: lastdaterange, message: message.text ?? ""))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .mapGBKString()
            .map { html -> Bool in
                let messages = try HtmlParser.chatMessges(from: html)
                if messages.count == 1 && messages[0].content == message.text {
                    return true
                }
                let result = try Regex.firstMatch(in: html, of: "\\[CDATA\\[([^<]+)<")
                if result.count == 2 && !result[1].isEmpty {
                    throw HtmlParserError.underlying("发送失败: \(result[1])")
                } else {
                    throw HtmlParserError.underlying("发送失败")
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .next(_):
                    completion(.success(()))
                case .error(let error):
                    self.messages = self.messages.filter { self.secondDateFormater.string(from: $0.date) != self.secondDateFormater.string(from: message.date) }
                    completion(.failure(error as NSError))
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - DataSource

extension ChatViewModel {
    func numberOfItems() -> Int {
        return messages.count
    }
    
    func message(at index: Int) -> JSQMessage {
        return messages[index]
    }
    
    func avatar(at index: Int) -> JSQMessagesAvatarImage? {
        return avatars[message(at: index).senderId]
    }
    
    func messageType(at index: Int) -> ChatMessageType {
        return message(at: index).senderId == "\(user.uid)" ? .incoming : .outgoing
    }
    
    func user(at index: Int) -> User {
        switch messageType(at: index) {
        case .incoming:
            return user
        case .outgoing:
            return User(name: Settings.shared.activeAccount?.name ?? "", uid: Settings.shared.activeAccount?.uid ?? 0)
        }
    }
    
    func shouldShowCellTopLabel(at index: Int) -> Bool {
        if index == 0 {
            return true
        }
        return dateString(at: index - 1) != dateString(at: index)
    }
    
    func dateString(at index: Int) -> String {
        return dateString(of: message(at: index).date)
    }
}
