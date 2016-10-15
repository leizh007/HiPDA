//
//  TestViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/13.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

class TestViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "测试"
    }
    @IBAction func buttonPressed(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func aaa(_ sender: AnyObject) {
        let testViewController = TestViewController.load(from: UIStoryboard.main)
        present(testViewController, animated: true, completion: nil)
    }
}

extension TestViewController: StoryboardLoadable {
    
}
