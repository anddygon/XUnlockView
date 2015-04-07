//
//  ViewController.swift
//  XGestureUnlock
//
//  Created by eduo_xiaoP on 15/4/6.
//  Copyright (c) 2015年 eduo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UnlockViewDelegate {

    @IBOutlet weak var track: UILabel!
    @IBOutlet weak var unlockView: XUnlockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        unlockView.delegate = self
    }
    
    func trackFinished(track: NSString) {
        self.track.text = "手势密码:" + track
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

