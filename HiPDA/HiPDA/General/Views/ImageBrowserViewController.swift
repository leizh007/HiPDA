//
//  ImageBrowserViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/28.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class ImageBrowserViewController: BaseViewController {
    var imageURLs: [String]!
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - StoryboardLoadable

extension ImageBrowserViewController: StoryboardLoadable {}
