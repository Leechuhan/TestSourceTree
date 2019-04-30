//
//  HomeViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/26.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import CloudKit

class HomeViewController: UIViewController {

    @IBOutlet weak var loadDate: UIActivityIndicatorView!
    @IBOutlet weak var currentMonth: UILabel!
    @IBOutlet weak var userAmount: UILabel!
    @IBOutlet weak var scanTicket: UIButton!
    @IBOutlet weak var keyinTicket: UIButton!
    @IBOutlet weak var ticketList: UIButton!
    @IBOutlet weak var openNumber: UIButton!
    @IBOutlet weak var versionCode: UILabel!
    
    let config = Config()
    let pubFunc = PubFunc()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ticketNums = [[Any]]()
    var recordNames = [String]()
    var version = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "Update"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateFinish), name: NSNotification.Name(rawValue: "UpdateFinish"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let iCloudStatus = pubFunc.check_iCloud_status()
        if iCloudStatus {
            scanTicket.isEnabled = true
            keyinTicket.isEnabled = true
            ticketList.isEnabled = true
        } else {
            self.appDelegate.addSubView(self_view: self, showMessage: "iCloud 雲碟未開啟\n無法取得資訊", loading: false ,status: config.warn)
            scanTicket.isEnabled = false
            keyinTicket.isEnabled = false
            ticketList.isEnabled = false
        }
        
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        versionCode.text = "ver \(version)"
        
        self.userAmount.isHidden = true
        self.currentMonth.isHidden = true
        
        loadDate.hidesWhenStopped = true
        loadDate.startAnimating()

        getUserTicketNums()
        getTicketNums()
    }
    
    @IBAction func selectFunc(_ sender: UIButton) {
        switch sender {
        case scanTicket:
            performSegue(withIdentifier: "ScanTicket", sender: nil)
        case keyinTicket:
            performSegue(withIdentifier: "KeyinTicket", sender: nil)
        case ticketList:
            performSegue(withIdentifier: "TicketList", sender: nil)
        case openNumber:
            performSegue(withIdentifier: "TicketNum", sender: nil)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "TicketNum":
            let ticketNumViewController = segue.destination as! TicketNumViewController
            ticketNumViewController.ticketNums = ticketNums
        default:
            break
        }
    }
    
    func getTicketNums() {
        var nums = [[Any]]()
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "TicketNumList", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if results!.count > 0 {
                for result in results! {
                    var info = [Any]()
                    info.append(result.object(forKey: "month") as! String)
                    info.append(result.object(forKey: "type") as! String)
                    info.append(result.object(forKey: "ticketNum") as! [String])
                    nums.append(info)
                }
                DispatchQueue.main.async {
                    self.ticketNums = nums
                }
            }
        })
    }
    
    func getUserTicketNums() {
        var allAmount = 0
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let day = dateFormatter.string(from: date)
        let dayAry = day.split(separator: "-")
        showMonthText(month: String(dayAry[1]))
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SaveTicketNum", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            for result in results! {
                let ticketDate = result.object(forKey: "date") as! String
                let ticketDateAry = ticketDate.split(separator: "-")
                if ticketDateAry[0] == dayAry[0] && ticketDateAry[1] == dayAry[1] {
                    let amount = result.object(forKey: "amount") as! String
                    allAmount += Int(amount)!
                }
            }
            DispatchQueue.main.async {
                self.loadDate.stopAnimating()
                self.userAmount.text = "$ " + String(allAmount)
                self.userAmount.isHidden = false
                self.currentMonth.isHidden = false
            }
        })
    }
    
    func showMonthText(month: String) {
        switch month {
        case "01":
            currentMonth.text = "Jan"
        case "02":
            currentMonth.text = "Feb"
        case "03":
            currentMonth.text = "Mar"
        case "04":
            currentMonth.text = "Apr"
        case "05":
            currentMonth.text = "May"
        case "06":
            currentMonth.text = "Jun"
        case "07":
            currentMonth.text = "Jul"
        case "08":
            currentMonth.text = "Aug"
        case "09":
            currentMonth.text = "Sep"
        case "10":
            currentMonth.text = "Oct"
        case "11":
            currentMonth.text = "Nov"
        case "12":
            currentMonth.text = "Dec"
        default:
            break
        }
    }
    
    //修正上版錯誤
//    @objc func updateData() {
//        var getDatas = [String]()
//        let cloudContainer = CKContainer.default()
//        let publicDatabase = cloudContainer.privateCloudDatabase
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "SaveTicketNum", predicate: predicate)
//        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
//            if results!.count > 0 {
//                DispatchQueue.main.async {
//                    self.appDelegate.addSubView(self_view: self, showMessage: "資料更新中", loading: true ,status: self.config.warn)
//                }
//                for result in results! {
//                    let recordName = result.recordID.recordName
//                    getDatas.append(recordName)
//                }
//                DispatchQueue.main.async {
//                    for r in getDatas {
//                        self.pubFunc.updateCheckResult(recodeName: r, check: "U", lastRecodeName: getDatas[getDatas.count-1])
//                    }
//                }
//            }
//        })
//    }
//
//    @objc func updateFinish() {
//        UserDefaults.standard.set(version, forKey: "Version")
//        UserDefaults.standard.synchronize()
//        appDelegate.removeSubView(self_view: self)
//        appDelegate.addSubView(self_view: self, showMessage: "資料更新完成", loading: false, status: config.finish)
//    }
    
}
