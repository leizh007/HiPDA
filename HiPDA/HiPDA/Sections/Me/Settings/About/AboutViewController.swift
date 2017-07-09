//
//  AboutViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/9.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import MessageUI
import AcknowList

fileprivate enum AbountSection: Int {
    case version
    case advise
    case acknowledgements
}

class AboutViewController: UITableViewController {
    @IBOutlet fileprivate var appIconContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "关于"
    }
    
    fileprivate func sendAdvise() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["leizh007@qq.com"])
            present(mail, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: "mailto:leizh007@qq.com")!)
        }
    }
    
    fileprivate func showAcknowledgementsViewController() {
        let path = Bundle.main.path(forResource: "Pods-HiPDA-acknowledgements", ofType: "plist")
        let viewController = AcknowListViewController(acknowledgementsPlistPath: path)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AboutViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? appIconContainerView : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 160.0 : 8.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = AbountSection(rawValue: indexPath.section) else { return }
        switch section {
        case .version:
            break
        case .advise:
            sendAdvise()
        case .acknowledgements:
            showAcknowledgementsViewController()
        }
    }
}

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
