//
//  TodayViewController.swift
//  BarcodeWidget
//
//  Created by Louis on 2019/4/15.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var userBarcode: UILabel!
    @IBOutlet weak var userCode: UILabel!
    @IBOutlet weak var openAppBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let getUserBarcode = UserDefaults(suiteName: "group.net.pixnet.leechuhan.scanticket.BarcodeWidget")!.value(forKey: "UserBarcode") as? String {
            openAppBtn.isEnabled = true
            userBarcode.text = "*\(getUserBarcode)*"
            userCode.text = getUserBarcode
        } else {
            userCode.text = "尚無手機條碼"
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func openApp(_ sender: UIButton) {
        let url = URL(string: "DoWay://")!
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
}
