//
//  KeyinTicketViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/28.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import CloudKit
import AudioToolbox

class KeyinTicketViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var ticketBottomConstain: NSLayoutConstraint!
    @IBOutlet weak var ticketPeriod: UITextField!
    @IBOutlet weak var ticketNum: UITextField!
    @IBOutlet weak var ticketDate: UITextField!
    @IBOutlet weak var ticketAmount: UITextField!
    @IBOutlet weak var uploadBtn: UIButton!
    
    var naviBar = UIView()
    var menuButton = UIButton()
    var dataPicker = UIPickerView()
    let pubFunc = PubFunc()
    let config = Config()
    var selectYear = ""
    var selectMonth = ""
    var selectDay = ""
    var selectPeriod = ""
    var textFieldID = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var year = [String]()
    var month = [String]()
    var day = [String]()
    let country = ["民國","年","月份","-"]
    var currentDateAry = [String.SubSequence]()
    var userInformation = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenHeight = UIScreen.main.bounds.height
        
        userInformation = UserDefaults.standard.dictionary(forKey: "UserInformation")!
        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnDefault), name: NSNotification.Name(rawValue: "ReturnDefault"), object: nil)
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: date)
        currentDateAry = currentDate.split(separator: "-")
        year = [String(Int(currentDateAry[0])!-1), String(Int(currentDateAry[0])!)]
        month = config.month
        day = pubFunc.days(year: Int(currentDateAry[0])!, month: Int(currentDateAry[1])!)
        
        
        naviBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/10)
        naviBar.backgroundColor = UIColor(red: 151/255, green: 206/255, blue: 224/255, alpha: 1.0)
        
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
        title.text = "輸入發票號碼"
        
        view.addSubview(naviBar)
        view.addSubview(title)
        view.addSubview(menuButton)
        
        dataPicker.delegate = self
        dataPicker.dataSource = self
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 219/255, blue: 219/255, alpha: 1)
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "確定", style: UIBarButtonItem.Style.plain, target: self, action: #selector(setTicketPeriod))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        ticketPeriod.inputView = dataPicker
        ticketPeriod.inputAccessoryView = toolBar
        ticketDate.inputView = dataPicker
        ticketDate.inputAccessoryView = toolBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func inputText(_ sender: UITextField) {
        let inputID = sender.accessibilityIdentifier!
        switch inputID {
        case "ticketPeriod":
            textFieldID = "ticketPeriod"
            let period = pubFunc.dateTitle(month: String(currentDateAry[1]), type: 0)
            selectYear = String(Int(currentDateAry[0])! - 1911)
            selectPeriod = period
            dataPicker.reloadAllComponents()
            dataPicker.selectRow(year.firstIndex(of: String(currentDateAry[0]))!, inComponent: 1, animated: true)
            dataPicker.selectRow(config.periodMonth.firstIndex(of: period)!, inComponent: 3, animated: true)
        case "ticketDate":
            textFieldID = "ticketDate"
            selectYear = String(currentDateAry[0])
            selectMonth = String(currentDateAry[1])
            selectDay = String(currentDateAry[2])
            dataPicker.reloadAllComponents()
            dataPicker.selectRow(year.firstIndex(of: String(currentDateAry[0]))!, inComponent: 0, animated: true)
            dataPicker.selectRow(month.firstIndex(of: String(currentDateAry[1]))!, inComponent: 2, animated: true)
            dataPicker.selectRow(day.firstIndex(of: String(currentDateAry[2]))!, inComponent: 4, animated: true)
        default:
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            if textFieldID == "ticketPeriod" {
                return 1
            }
            
            if textFieldID == "ticketDate" {
                return year.count
            }
        case 1:
            if textFieldID == "ticketPeriod" {
                return year.count
            }
            
            if textFieldID == "ticketDate" {
                return 1
            }
        case 2:
            if textFieldID == "ticketPeriod" {
                return 1
            }
            
            if textFieldID == "ticketDate" {
                return month.count
            }
        case 3:
            if textFieldID == "ticketPeriod" {
                return config.periodMonth.count
            }
            
            if textFieldID == "ticketDate" {
                return 1
            }
        case 4:
            if textFieldID == "ticketPeriod" {
                return 1
            }
            
            if textFieldID == "ticketDate" {
                return day.count
            }
        default:
            break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var message = ""
        switch component {
        case 0:
            if textFieldID == "ticketPeriod" {
                message = country[0]
            }
            
            if textFieldID == "ticketDate" {
                message = year[row]
            }
        case 1:
            if textFieldID == "ticketPeriod" {
                 message = String(Int(year[row])!-1911)
            }
            
            if textFieldID == "ticketDate" {
                 message = country[3]
            }
        case 2:
            if textFieldID == "ticketPeriod" {
                message = country[1]
            }
            
            if textFieldID == "ticketDate" {
                message = month[row]
            }
        case 3:
            if textFieldID == "ticketPeriod" {
                message = config.periodMonth[row]
            }
            
            if textFieldID == "ticketDate" {
                message = country[3]
            }
        case 4:
            if textFieldID == "ticketPeriod" {
                message = country[2]
            }
            
            if textFieldID == "ticketDate" {
                message = day[row]
            }
        default:
            break
        }
        return message
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if textFieldID == "ticketPeriod" {
                
            }
            
            if textFieldID == "ticketDate" {
                selectYear = year[row]
                if selectYear != "" && selectMonth != "" {
                    day = pubFunc.days(year: Int(selectYear)!, month: Int(selectMonth)!)
                    dataPicker.reloadComponent(4)
                }
            }
        case 1:
            if textFieldID == "ticketPeriod" {
                selectYear = String(Int(year[row])!-1911)
            }
            
            if textFieldID == "ticketDate" {
                
            }
        case 2:
            if textFieldID == "ticketPeriod" {
                
            }
            
            if textFieldID == "ticketDate" {
                selectMonth = month[row]
                if selectYear != "" && selectMonth != "" {
                    day = pubFunc.days(year: Int(selectYear)!, month: Int(selectMonth)!)
                    dataPicker.reloadComponent(4)
                }
            }
        case 3:
            if textFieldID == "ticketPeriod" {
                selectPeriod = config.periodMonth[row]
            }
        
            if textFieldID == "ticketDate" {
                
            }
        case 4:
            if textFieldID == "ticketPeriod" {
                
            }
            
            if textFieldID == "ticketDate" {
                selectDay = day[row]
            }
        default:
            break
        }
    }
    
    @objc func setTicketPeriod() {
        if textFieldID == "ticketPeriod" {
            ticketPeriod.text = "中華民國"+selectYear+"年"+selectPeriod+"月份"
            ticketPeriod.resignFirstResponder()
        }
        
        if textFieldID == "ticketDate" {
            ticketDate.text = selectYear+"-"+selectMonth+"-"+selectDay
            ticketDate.resignFirstResponder()
        }
    }
    
    @IBAction func getTicketInfo(_ sender: UIButton) {
        uploadBtn.setBackgroundImage(UIImage(named: "SendingBtn"), for: .normal)
        
        if (ticketPeriod.text != "" && ticketNum.text != "" && ticketDate.text != "" && ticketAmount.text != "") {
            var ticketInfo = [String:Any]()
            var numberAry = [String]()
            var numberChaAry = [Character]()
            let number = ticketNum.text!
            
            if number.count == 10 {
                for i in number {
                    numberAry.append(String(i))
                }
                
                for i in 0...number.count-1 {
                    if i < 2 {
                        guard let check_ascii = UnicodeScalar(numberAry[i].uppercased())?.value else { return }
                        if Int(check_ascii) < 65 || Int(check_ascii) > 90 {
                            self.uploadBtn.setBackgroundImage(UIImage(named: "ErrorBtn"), for: .normal)
                            self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼前兩碼必需為英文字母", loading: false ,status: config.warn)
                            return
                        } else {
                            numberChaAry.append(Character(numberAry[i].uppercased()))
                        }
                    } else {
                        if Int(numberAry[i]) == nil {
                            self.uploadBtn.setBackgroundImage(UIImage(named: "ErrorBtn"), for: .normal)
                            self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼後八碼必需為數字", loading: false ,status: config.warn)
                            return
                        } else {
                            numberChaAry.append(Character(numberAry[i]))
                        }
                    }
                }
                
                numberChaAry.insert("-", at: 2)
                
                ticketInfo["ticketNum"] = String(numberChaAry)
                ticketInfo["date"] = ticketDate.text
                ticketInfo["info"] = []
                ticketInfo["cost"] = ticketAmount.text
                ticketInfo["check"] = "U"
                saveScanTicket(detail: ticketInfo)
            } else {
                self.uploadBtn.setBackgroundImage(UIImage(named: "ErrorBtn"), for: .normal)
                self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼輸入不完全", loading: false ,status: config.warn)
            }
        } else {
            uploadBtn.setBackgroundImage(UIImage(named: "ErrorBtn"), for: .normal)
            if ticketPeriod.text == "" {
                self.appDelegate.addSubView(self_view: self, showMessage: "請選擇發票期數", loading: false ,status: config.warn)
                return
            }
            
            if ticketNum.text == "" {
                self.appDelegate.addSubView(self_view: self, showMessage: "請輸入發票號碼", loading: false ,status: config.warn)
                return
            }
            
            if ticketDate.text == "" {
                self.appDelegate.addSubView(self_view: self, showMessage: "請輸入發票日期", loading: false ,status: config.warn)
                return
            }
            
            if ticketAmount.text == "" {
                self.appDelegate.addSubView(self_view: self, showMessage: "請輸入消費金額", loading: false ,status: config.warn)
                return
            }
        }
    }
    
    func saveScanTicket(detail: [String:Any]) {
        let id = userInformation["id"] as! String
        let email = userInformation["email"] as! String
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.privateCloudDatabase
        let infoID = CKRecord.ID(recordName: id + "-" + (detail["ticketNum"] as! String))
        let info = CKRecord(recordType: "SaveTicketNum", recordID: infoID)
        info.setValue(id, forKey: "id")
        info.setValue(email, forKey: "mail")
        info.setValue(detail["ticketNum"] as! String, forKey: "num")
        info.setValue(detail["date"] as! String, forKey: "date")
        info.setValue(detail["info"] as! [String], forKey: "info")
        info.setValue(detail["cost"] as! String, forKey: "amount")
        info.setValue(detail["check"] as! String, forKey: "check")
        publicDatabase.save(info) { (record, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.pubFunc.hitUser()
                    self.uploadBtn.setBackgroundImage(UIImage(named: "PassBtn"), for: .normal)
                    self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼儲存完成", loading: false ,status: self.config.finish)
                    self.ticketPeriod.text = ""
                    self.ticketNum.text = ""
                    self.ticketDate.text = ""
                    self.ticketAmount.text = ""
                }
            } else {
                DispatchQueue.main.async {
                    self.pubFunc.hitUser()
                    self.uploadBtn.setBackgroundImage(UIImage(named: "ErrorBtn"), for: .normal)
                    self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼已存在", loading: false ,status: self.config.warn)
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ticketPeriod.resignFirstResponder()
        ticketNum.resignFirstResponder()
        ticketDate.resignFirstResponder()
        ticketAmount.resignFirstResponder()
        dismissKeyboard()
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func returnDefault() {
        uploadBtn.setBackgroundImage(UIImage(named: "DefaultBtn"), for: .normal)
    }
    
    @objc func mainMenuAct() {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }

}
