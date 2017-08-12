//
//  BackgroundFetchManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/10.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

class BackgroundFetchManager: NSObject, Bootstrapping {
    fileprivate var disposeBag = DisposeBag()
    static let shared = BackgroundFetchManager()
    fileprivate var completionHandler: ((UIBackgroundFetchResult) -> Void)?
    
    func bootstrap(bootstrapped: Bootstrapped) throws {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    func performFetch(with completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard Settings.shared.isEnabledMessagePush && !isUserBlockNotificationDueToPmDoNotDisturb() else {
            completionHandler(.noData)
            return
        }
        self.completionHandler = completionHandler
        perform(#selector(cancelBackgroundFetchDueToTimeOut), with: nil, afterDelay: 5)
        if let account = Settings.shared.activeAccount, let _ = CookieManager.shared.cookies(for: account) {
            // 已登录态, 去请求一下首页，获取一下未读消息的数量
            NetworkUtilities.html(from: "/forum/index.php")
        }
        EventBus.shared.unReadMessagesCount.asObservable().subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            if model.totalMessagesCount == 0 || !self.shouldPostNotification(with: model) {
                UIApplication.shared.applicationIconBadgeNumber = 0
                completionHandler(.noData)
            } else {
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
                notification.alertBody = self.alertBody(from: model)
                notification.alertAction = "删除"
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = model.totalMessagesCount
                UIApplication.shared.scheduleLocalNotification(notification)
                completionHandler(.newData)
            }
            self.cancelTimer()
            self.disposeBag = DisposeBag()
        }).disposed(by: disposeBag)
    }
    
    fileprivate func alertBody(from model: UnReadMessagesCountModel) -> String {
        if model.totalMessagesCount == model.threadMessagesCount {
            return "您有\(model.threadMessagesCount)条帖子消息。"
        } else if model.totalMessagesCount == model.privateMessagesCount {
            return "您有\(model.privateMessagesCount)条私人消息。"
        } else if model.totalMessagesCount == model.friendMessagesCount {
            return "您有\(model.friendMessagesCount)条好友消息。"
        }
        return "您有\(model.totalMessagesCount)条新消息。"
    }
    
    fileprivate func shouldPostNotification(with model: UnReadMessagesCountModel) -> Bool {
        if model.totalMessagesCount == model.threadMessagesCount {
            return Settings.shared.isEnabledThreadPm
        } else if model.totalMessagesCount == model.privateMessagesCount {
            return Settings.shared.isEnabledPrivatePm
        } else if model.totalMessagesCount == model.friendMessagesCount {
            return Settings.shared.isEnabledFriendPm
        }
        return true
    }
    
    fileprivate func isUserBlockNotificationDueToPmDoNotDisturb() -> Bool {
        if Settings.shared.isEnabledPmDoNotDisturb {
            let time = Calendar.current.component(.hour, from: Date()) * 60 + Calendar.current.component(.minute, from: Date())
            let fromTime = Settings.shared.pmDoNotDisturbFromTime.hour * 60 + Settings.shared.pmDoNotDisturbFromTime.minute
            let toTime = Settings.shared.pmDoNotDisturbToTime.hour * 60 + Settings.shared.pmDoNotDisturbToTime.minute
            return time > fromTime || time < toTime
        } else {
            return false
        }
    }
    
    func cancelTimer() {
        completionHandler = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelBackgroundFetchDueToTimeOut), object: nil)
    }
    
    @objc fileprivate func cancelBackgroundFetchDueToTimeOut() {
        disposeBag = DisposeBag()
        completionHandler?(.failed)
        completionHandler = nil
    }
}
