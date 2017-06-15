//
//  ImagePickerViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class ImagePickerViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(confirm))
    }
}

// MARK: - Button Actions

extension ImagePickerViewController {
    func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func confirm() {
        
    }
}

// MARK: - StoryboardLoadable

extension ImagePickerViewController: StoryboardLoadable { }
