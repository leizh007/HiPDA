//
//  a.swift
//  test
//
//  Created by leizh007 on 16/2/2.
//  Copyright © 2016年 leizh007. All rights reserved.
//

import UIKit

class a: UIViewController {
    var bController: b!
    var cController: c! 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.greenColor()
        
        bController = b()
        cController = c()
        displayContentController(bController, toFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        displayContentController(cController, toFrame: CGRect(x: 0, y: 100, width: 100, height: 100))
    }
}
