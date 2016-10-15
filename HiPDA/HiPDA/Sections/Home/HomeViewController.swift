//
//  HomeViewController.swift
//  HiPDA
//
//  Created by leizh007 on 16/9/3.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import UIKit

/// 主页的ViewController
class HomeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Discovery"
    }
    @IBAction func buttonPressed(_ sender: AnyObject) {
        let testViewController = TestViewController.load(from: UIStoryboard.main)
        present(testViewController, animated: true, completion: nil)
    }
}
