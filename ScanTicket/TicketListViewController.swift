//
//  TicketListViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/28.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import CloudKit

class TicketListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var selectMonth: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let config = Config()
    let pubFunc = PubFunc()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var naviBar = UIView()
    var menuButton = UIButton()
    var selectMonthIndex = 0
    var selectYear = 0
    var dayAry = [String.SubSequence]()
    var ticketList = [(key: [String], value: String)]()
    var needCheckTicketList = [(key: [String], value: String)]()
    var unNeedCheckTicketList = [(key: [String], value: String)]()
    var ticketNums = [String:[String]]()
    var userNumsInfo = [(key: [String], value: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFinish), name: NSNotification.Name(rawValue: "CheckFinish"), object: nil)
        
        let screenHeight = UIScreen.main.bounds.height
        
        naviBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/10)
        naviBar.backgroundColor = UIColor(red: 176/255, green: 217/255, blue: 226/255, alpha: 1.0)
        
        if screenHeight <= 736.0 {
            menuButton = UIButton(frame: CGRect(x: 5, y: 15, width: 50, height: 50))
        } else {
            menuButton = UIButton(frame: CGRect(x: 5, y: 35, width: 50, height: 50))
        }
        menuButton.setImage(UIImage(named: "Menu"), for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(mainMenuAct), for: .touchUpInside)
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/10))
        if screenHeight <= 736.0 {
            title.center = CGPoint(x: self.view.frame.width/2, y: 42)
        } else {
            title.center = CGPoint(x: self.view.frame.width/2, y: 62)
        }
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 18.0)
        title.text = "發票清單"
        
        view.addSubview(naviBar)
        view.addSubview(title)
        view.addSubview(menuButton)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let day = dateFormatter.string(from: date)
        dayAry = day.split(separator: "-")
        selectYear = Int(dayAry[0])! - 1911
        selectMonthIndex = Int(dayAry[1])!-1
        selectMonth.text = String(selectYear)+"年"+config.month[selectMonthIndex]+"月"
        nextBtn.isEnabled = false
        
        getUserTicketNums(month: String(dayAry[1]))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TicketInfoTableViewCell
        cell.day.text = ticketList[indexPath.row].value
        cell.num.text = ticketList[indexPath.row].key[0]
        cell.amount.text = "小計：" + ticketList[indexPath.row].key[1]
        if ticketList[indexPath.row].key[2] == "U" {
            cell.checkImg.image = UIImage(named: "UnCheck")
        } else if ticketList[indexPath.row].key[2] == "8" {
            cell.checkImg.image = UIImage(named: "UnBingo")
        } else {
            cell.checkImg.image = UIImage(named: "Bingo_" + ticketList[indexPath.row].key[2])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(recodeName: ticketList[indexPath.row].key[3])
            ticketList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    
    @IBAction func changeMonth(_ sender: UIButton) {
        let buttonID = sender.accessibilityIdentifier!
        switch buttonID {
        case "Back":
            if selectMonthIndex == 0 {
                selectYear -= 1
                selectMonthIndex = 11
            } else {
                selectMonthIndex -= 1
            }
            
            selectMonth.text = String(selectYear)+"年"+config.month[selectMonthIndex]+"月"
            
            if selectYear == Int(dayAry[0])! && selectMonthIndex == Int(dayAry[1])! - 1 {
                nextBtn.isEnabled = false
            } else {
                nextBtn.isEnabled = true
            }
            
            getUserTicketNums(month: config.month[selectMonthIndex])
        case "Next":
            if selectMonthIndex == 11 {
                selectYear += 1
                selectMonthIndex = 0
            } else {
                selectMonthIndex += 1
            }
            
            selectMonth.text = String(selectYear)+"年"+config.month[selectMonthIndex]+"月"
            
            if selectYear == Int(dayAry[0])! - 1911 && selectMonthIndex == Int(dayAry[1])! - 1 {
                nextBtn.isEnabled = false
            } else {
                nextBtn.isEnabled = true
            }
            
            getUserTicketNums(month: config.month[selectMonthIndex])
        default:
            break
        }
    }
    
    @objc func getUserTicketNums(month: String) {
        appDelegate.addSubView(self_view: self, showMessage: "取得發票號碼", loading: true, status: config.finish)
        var checkTicket = [(key: [String], value: String)]()
        var unCheckTicket = [(key: [String], value: String)]()
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "SaveTicketNum", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            for result in results! {
                let date = result.object(forKey: "date") as! String
                let dateAry = date.split(separator: "-")
                let result_month = String(dateAry[1])
                if result_month == month {
                    if result.object(forKey: "check") as! String == "U" {
                        let result_day = String(dateAry[2])
                        var info = [String]()
                        info.append(result.object(forKey: "num") as! String)
                        info.append(result.object(forKey: "amount") as! String)
                        info.append(result.object(forKey: "check") as! String)
                        info.append(result.recordID.recordName)
                        let ticketData = (key: info, value: result_day)
                        unCheckTicket.append(ticketData)
                    } else {
                        let result_day = String(dateAry[2])
                        var info = [String]()
                        info.append(result.object(forKey: "num") as! String)
                        info.append(result.object(forKey: "amount") as! String)
                        info.append(result.object(forKey: "check") as! String)
                        info.append(result.recordID.recordName)
                        let ticketData = (key: info, value: result_day)
                        checkTicket.append(ticketData)
                    }
                }
            }
            DispatchQueue.main.async {
                self.needCheckTicketList = unCheckTicket
                self.unNeedCheckTicketList = checkTicket
                self.getTicketNums(month: month)
            }
        })
    }
    
    @objc func getTicketNums(month: String) {
        var nums = [String:[String]]()
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "TicketNumList", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if results!.count > 0 {
                for result in results! {
                    if (result.object(forKey: "month") as! String).contains(month) {
                        nums[result.object(forKey: "type") as! String] = (result.object(forKey: "ticketNum") as! [String])
                    }
                }
                DispatchQueue.main.async {
                    self.ticketNums = nums
                    self.checkTicketNum(checkNum: self.ticketNums, userNums: self.needCheckTicketList)
                }
            }
        })
    }
    
    func checkTicketNum(checkNum: [String:[String]], userNums: [(key: [String], value: String)]) {
        if checkNum.count == 0 {
            let needCheckTicketList_fix = needCheckTicketList.sorted { (str1, str2) -> Bool in
                return str1.1 < str2.1
            }
            ticketList = needCheckTicketList_fix
            tableView.reloadData()
            appDelegate.removeSubView(self_view: self)
        } else {
            if userNums.count == 0 {
                let unNeedCheckTicketList_fix = self.unNeedCheckTicketList.sorted { (str1, str2) -> Bool in
                    return str1.1 < str2.1
                }
                self.ticketList = unNeedCheckTicketList_fix
                self.tableView.reloadData()
                appDelegate.removeSubView(self_view: self)
            } else {
                appDelegate.removeSubView(self_view: self)
                appDelegate.addSubView(self_view: self, showMessage: "自動對獎", loading: true, status: config.finish)
                userNumsInfo = userNums
                for i in 0...userNums.count - 1 {
                    var isBingo = false
                    let userTicket = userNums[i].key[0]
                    let userTicketAry = userTicket.split(separator: "-")
                    let userTicketNum = String(userTicketAry[1])
                    
                    if userTicketNum == checkNum["0"]![0] {
                        userNumsInfo[i].key[2] = "0"
                        pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: "0", lastRecodeName: userNums[userNums.count-1].key[3])
                        break
                    }
                    
                    if userTicketNum == checkNum["1"]![0] {
                        userNumsInfo[i].key[2] = "1"
                        pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: "1", lastRecodeName: userNums[userNums.count-1].key[3])
                        break
                    }
                    
                    for tns in 0...2 {
                        for tn in 3...8 {
                            let ticketNum = String(userTicketNum.suffix(tn))
                            let checkNum = String(checkNum["2"]![tns].suffix(tn))
                            if ticketNum == checkNum {
                                if tn == 8 {
                                    isBingo = true
                                    userNumsInfo[i].key[2] = String(tn-1)
                                    pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: String(tn-1), lastRecodeName: userNums[userNums.count-1].key[3])
                                    break
                                }
                            } else {
                                if tn-1 == 2 {
                                    isBingo = false
                                    break
                                }
                                isBingo = true
                                userNumsInfo[i].key[2] = String(tn-1)
                                pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: String(tn-1), lastRecodeName: userNums[userNums.count-1].key[3])
                                break
                            }
                        }
                        
                        if isBingo {
                            break
                        } else {
                            continue
                        }
                    }
                    
                    if !isBingo {
                        for addTns in 0...checkNum["3"]!.count-1 {
                            let ticketNum = String(userTicketNum.suffix(3))
                            if ticketNum == checkNum["3"]![addTns] {
                                isBingo = true
                                userNumsInfo[i].key[2] = "7"
                                pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: "7", lastRecodeName: userNums[userNums.count-1].key[3])
                                break
                            }
                        }
                    }
                    
                    if !isBingo {
                        userNumsInfo[i].key[2] = "8"
                        pubFunc.updateCheckResult(recodeName: userNums[i].key[3], check: String(8), lastRecodeName: userNums[userNums.count-1].key[3])
                    }
                }
            }
        }
    }
    
    func deleteData(recodeName: String) {
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.privateCloudDatabase
        let infoID = CKRecord.ID(recordName: recodeName)
        privateDatabase.delete(withRecordID: infoID) { (recode, error) in
            if error != nil {
                print("delete finish")
            }
        }
    }
    
    @objc func updateFinish() {
        let allTickets = unNeedCheckTicketList + userNumsInfo
        let allTickets_fix = allTickets.sorted { (str1, str2) -> Bool in
            return str1.1 < str2.1
        }
        self.ticketList = allTickets_fix
        tableView.reloadData()
        appDelegate.removeSubView(self_view: self)
    }
    
    @objc func mainMenuAct() {
        dismiss(animated: true, completion: nil)
    }
    
}
