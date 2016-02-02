//
//  ViewController.swift
//  test
//
//  Created by leizh007 on 16/2/2.
//  Copyright © 2016年 leizh007. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var aController: a!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        aController = a()
        displayContentController(aController, toFrame: view.bounds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

