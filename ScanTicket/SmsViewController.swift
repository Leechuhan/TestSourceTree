//
//  SmsViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/4/12.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import FirebaseAuth

class SmsViewController: UIViewController {

    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var checkCode: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var num = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtn.isEnabled = false
    }
    
    @IBAction func send(_ sender: UIButton) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNum.text!, uiDelegate: nil) { (verID, error) in
            if error != nil {
               
            } else {
                DispatchQueue.main.async {
                    self.num = verID!
                    self.sendBtn.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        let credentail = PhoneAuthProvider.provider().credential(withVerificationID: num, verificationCode: checkCode.text!)
        Auth.auth().signInAndRetrieveData(with: credentail) { (result, error) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
