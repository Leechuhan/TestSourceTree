//
//  LoginViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/29.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {

    var isSuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isSuccess {
            performSegue(withIdentifier: "HomePage", sender: nil)
        }
    }
    
    @IBAction func loginAct(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile,.email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed:
                print("error")
            case .cancelled:
                print("the user cancels login")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                self.getDetails()
            }
        }
    }
    
    func getDetails() {
        guard let _ = AccessToken.current else {return}
        let param = ["fields":"email"]
        let graphRequest = GraphRequest(graphPath: "me",parameters: param)
        graphRequest.start { (urlResponse, requestResult) in
            switch requestResult {
            case .failed:
                print("error")
            case .success(response: let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    DispatchQueue.main.async {
                        self.isSuccess = true
                        UserDefaults.standard.set(responseDictionary, forKey: "UserInformation")
                    }
                }
            }
        }
    }

}
