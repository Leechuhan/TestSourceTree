//
//  TicketNumViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/27.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit

class TicketNumViewController: UIViewController {

    @IBOutlet weak var ticketMonth: UILabel!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var ssNum: UILabel!
    @IBOutlet weak var sNum: UILabel!
    @IBOutlet weak var nNum: UILabel!
    @IBOutlet weak var aNum: UILabel!
    
    var naviBar = UIView()
    var menuButton = UIButton()
    var ticketNums = [[Any]]()
    var ticketTitles = [String]()
    var selectIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        title.text = "對獎號碼"
        
        view.addSubview(naviBar)
        view.addSubview(title)
        view.addSubview(menuButton)
        
        ticketTitles = showMonth()
        let titleComponent = ticketTitles[1].split(separator: "/")
        ticketMonth.text = titleComponent[0]+"年"+titleComponent[1]+"月"
        nextBtn.isEnabled = false
        
        showTicketNumList(selectMonth: ticketTitles[1], ticketNums: ticketNums)
    }
    
    @IBAction func beforeMonth(_ sender: UIButton) {
        let titleComponent = ticketTitles[0].split(separator: "/")
        ticketMonth.text = titleComponent[0]+"年"+titleComponent[1]+"月"
        beforeBtn.isEnabled = false
        nextBtn.isEnabled = true
        showTicketNumList(selectMonth: ticketTitles[0], ticketNums: ticketNums)
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        let titleComponent = ticketTitles[1].split(separator: "/")
        ticketMonth.text = titleComponent[0]+"年"+titleComponent[1]+"月"
        beforeBtn.isEnabled = true
        nextBtn.isEnabled = false
        showTicketNumList(selectMonth: ticketTitles[1], ticketNums: ticketNums)
    }
    
    func showMonth() -> [String] {
        var chooseMonth = [String]()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let day = dateFormatter.string(from: date)
        let dayComponent = day.split(separator: "-")
        let dateInt = Int(dayComponent[1]+dayComponent[2])!
        let year = String(Int(String(dayComponent[0]))!-1911)
        
        if dateInt >= 125 && dateInt < 325 {
            chooseMonth = [String(Int(year)!-1)+"/09-10", String(Int(year)!-1)+"/11-12"]
            return chooseMonth
        }
        
        if dateInt >= 325 && dateInt < 525 {
            chooseMonth = [String(Int(year)!-1)+"/11-12", year+"/01-02"]
            return chooseMonth
        }
        
        if dateInt >= 525 && dateInt < 725 {
            chooseMonth = [year+"/01-02", year+"/03-04"]
            return chooseMonth
        }
        
        if dateInt >= 725 && dateInt < 925 {
            chooseMonth = [year+"/03-04", year+"/05-06"]
            return chooseMonth
        }
        
        if dateInt >= 925 && dateInt < 1125 {
            chooseMonth = [year+"/05-06", year+"/07-08"]
            return chooseMonth
        }
        
        if dateInt < 125 && dateInt >= 1125 {
            chooseMonth = [year+"/07-08", year+"/09-10"]
            return chooseMonth
        }
        
        return []
    }
    
    func showTicketNumList(selectMonth: String, ticketNums: [[Any]]) {
        ssNum.text = "-"
        sNum.text = "-"
        nNum.text = "-"
        aNum.text = "-"
        var selectTicketNums = [[Any]]()
        for ticketNum in ticketNums {
            if (ticketNum[0] as! String) == selectMonth {
                selectTicketNums.append(ticketNum)
            }
        }
        
        if selectTicketNums.count == 0 {
            return
        }
        
        for ticketNum in selectTicketNums {
            if (ticketNum[0] as! String) == selectMonth {
                if (ticketNum[1] as! String) == "0" {
                    let nums = ticketNum[2] as! [String]
                    ssNum.text = nums[0]
                }
                
                if (ticketNum[1] as! String) == "1" {
                    let nums = ticketNum[2] as! [String]
                    sNum.text = nums[0]
                }
                
                if (ticketNum[1] as! String) == "2" {
                    let nums = ticketNum[2] as! [String]
                    var numsStr = ""
                    for i in 0...nums.count - 1 {
                        if i != nums.count - 1 {
                            numsStr += nums[i]+"\n"
                        } else {
                            numsStr += nums[i]
                        }
                    }
                    nNum.text = numsStr
                }
                
                if (ticketNum[1] as! String) == "3" {
                    let nums = ticketNum[2] as! [String]
                    var numsStr = ""
                    for i in 0...nums.count - 1 {
                        if i != nums.count - 1 {
                            numsStr += nums[i]+"、"
                        } else {
                            numsStr += nums[i]
                        }
                    }
                    aNum.text = numsStr
                }
            }
        }
    }
    
    @objc func mainMenuAct() {
        dismiss(animated: true, completion: nil)
    }

}
