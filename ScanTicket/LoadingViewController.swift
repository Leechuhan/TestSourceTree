//
//  LoadingViewController.swift
//  apiSystem
//
//  Created by Louis on 2019/2/25.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var showMessage: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var message = ""
    var isLoading = false
    var showImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.hidesWhenStopped = true
        alertView.layer.cornerRadius = 7.0
        statusImg.image = showImg
        
        if isLoading {
            statusImg.isHidden = true
            loading.startAnimating()
        } else {
            statusImg.isHidden = false
            statusImg.image = showImg
            loading.stopAnimating()
        }
        
        showMessage.text = message
    }
}
