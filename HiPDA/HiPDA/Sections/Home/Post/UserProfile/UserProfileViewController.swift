//
//  UerProfileViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/22.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

protocol UserProfileDelegate: class {
    func userProfileInformationDidChange()
}

class UserProfileViewController: UIViewController {
    var uid: Int!
    fileprivate var viewModel: UserProfileViewModel!
    @IBOutlet fileprivate weak var tableView: BaseTableView!
    fileprivate var sectionHeaderViews = [Int: UserProfileSectionHeaderView]()
    weak var delegate: UserProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "个人资料"
        viewModel = UserProfileViewModel(uid: uid)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dataLoadDelegate = self
        tableView.hasLoadMoreFooter = false
        tableView.keyboardDismissMode = .onDrag
        tableView.status = .loading
        loadNewData()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        guard parent == nil, viewModel.didUserProfileChanged() else { return }
        delegate?.userProfileInformationDidChange()
    }
}

// MARK: - UITableViewDelegate

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = viewModel.section(at: indexPath.section)
        switch section {
        case .account(_):
            return 87
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 14.0
        }
        return viewModel.section(at: section).header == nil ? .leastNormalMagnitude : 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        guard case let .action(action) = viewModel.section(at: indexPath.section) else { return }
        switch action.items[indexPath.row] {
        case .block:
            viewModel.changeBlockState()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .friend:
            showPromptInformation(of: .loading("正在添加好友..."))
            viewModel.addFriend { [weak self] result in
                self?.hidePromptInformation()
                switch result {
                case .success(let info):
                    self?.showPromptInformation(of: .success(info))
                case .failure(let error):
                    self?.showPromptInformation(of: .failure(error.localizedDescription))
                }
            }
        case .pm:
            let sendMessageVC = SendShortMessageViewController.load(from: .message)
            sendMessageVC.modalPresentationStyle = .overCurrentContext
            present(sendMessageVC, animated: false, completion: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = viewModel.section(at: section)
        guard let header = sectionModel.header else { return nil }
        let headerView: UserProfileSectionHeaderView
        if let view = sectionHeaderViews[section] {
            headerView = view
        } else {
            headerView = Bundle.main.loadNibNamed("UserProfileSectionHeaderView",
                                                  owner: self,
                                                  options: nil)!.first as! UserProfileSectionHeaderView
            sectionHeaderViews[section] = headerView
        }
        headerView.headerTitle = header
        headerView.tag = section
        headerView.delegate = self
        
        return headerView
    }
}

// MARK: - UserProfileSectionHeaderDelegate

extension UserProfileViewController: UserProfileSectionHeaderDelegate {
    func sectionHeaderDidTapped(_ sectionHeader: UserProfileSectionHeaderView) {
        view.endEditing(true)
        let sectionIndex = sectionHeader.tag
        guard sectionIndex < viewModel.numberOfSections() else { return }
        viewModel.changeSectionHeaderCollapse(at: sectionIndex)
        tableView.reloadSections([sectionIndex], animationStyle: .automatic)
    }
}

// MARK: - UITableViewDataSource

extension UserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.section(at: indexPath.section)
        switch section {
        case let .account(account):
            return cell(for: account, at: indexPath)
        case let .action(action):
            return cell(for: action, at: indexPath)
        case let .baseInfo(baseInfo):
            return cell(for: baseInfo, at: indexPath)
        }
    }
    
    private func cell(for section: ProfileAccountSection, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as UserProfileAccountTableViewCell
        cell.user = section.items[indexPath.row]
        
        return cell
    }
    
    private func cell(for section: ProfileActionSection, at indexPath: IndexPath) -> UITableViewCell {
        let action = section.items[indexPath.row]
        switch action {
        case .remark:
            let cell = tableView.dequeueReusableCell(for: indexPath) as UserProfileRemarkTableViewCell
            cell.remark = viewModel.remark
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(for: indexPath) as UserProfileActionTableViewCell
            cell.action = action == .block ? viewModel.blockTitle : action.description
            cell.accessoryType = action == .block ? .none : .disclosureIndicator
            
            return cell
        }
    }
    
    private func cell(for section: ProfileBaseInfoSection, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as UserProfileBaseInfoTableViewCell
        cell.baseInfo = section.items[indexPath.row]
        
        return cell
    }
}

// MARK: - UserProfileRemarkDelegate

extension UserProfileViewController: UserProfileRemarkDelegate {
    func remarkDidChange(_ remark: String?) {
        viewModel.remark = remark
    }
}

// MARK: - DataLoadDelegate

extension UserProfileViewController: DataLoadDelegate {
    func loadNewData() {
        viewModel.refresh { [weak self] result in
            guard let `self` = self else { return }
            self.tableView.endRefreshing()
            switch result {
            case .success(_):
                self.tableView.status = .normal
                self.tableView.reloadData()
                self.title = "\(self.viewModel.name)的个人资料"
            case .failure(let error):
                self.showPromptInformation(of: .failure(error.localizedDescription))
                if self.tableView.status == .loading {
                    self.tableView.status = .tapToLoad
                } else {
                    self.tableView.status = .normal
                }
            }
        }
    }
}

// MARK: - StoryboardLoadable

extension UserProfileViewController: StoryboardLoadable { }
