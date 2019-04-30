//
//  PubFunc.swift
//  ScanTicket
//
//  Created by Louis on 2019/4/2.
//  Copyright © 2019 louis. All rights reserved.
//

import Foundation
import CloudKit
import AudioToolbox

class PubFunc {
    
    func days(year: Int, month: Int) -> [String] {
        var allDays = [String]()
        var dayNum = 0
        if month != 2 {
            if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
                dayNum = 31
            }
            if month == 4 || month == 6 || month == 9 || month == 11 {
                dayNum = 30
            }
        } else {
            if year % 4 != 0 {
                dayNum = 28
            } else {
                dayNum = 29
            }
        }
        for i in 1 ... dayNum {
            let day = String(format: "%02d", i)
            allDays.append(String(day))
        }
        return allDays
    }
    
    func dateTitle(month: String, type: Int) -> String {
        var period = ""
        switch month {
        case "01","02":
            if type == 0 {
                period = "1-2"
            } else {
                period = "01-02"
            }
        case "03","04":
            if type == 0 {
                period = "3-4"
            } else {
                period = "03-04"
            }
        case "05","06":
            if type == 0 {
                period = "5-6"
            } else {
                period = "05-06"
            }
        case "07","08":
            if type == 0 {
                period = "7-8"
            } else {
                period = "07-08"
            }
        case "09","10":
            if type == 0 {
                period = "9-10"
            } else {
                period = "09-10"
            }
        case "11","12":
            period = "11-12"
        default:
            break
        }
        
        return period
    }
    
    func check_iCloud_status() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        } else {
            return false
        }
    }
    
    func hitUser() {
        let soundID = SystemSoundID(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(soundID)
    }
    
    func updateCheckResult(recodeName: String, check: String, lastRecodeName: String) {
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.privateCloudDatabase
        let infoID = CKRecord.ID(recordName: recodeName)
        privateDatabase.fetch(withRecordID: infoID) { (record, error) in
            if error == nil {
                record!["check"] = check
                privateDatabase.save(record!, completionHandler: { (record, error) in
                    if error != nil {
                        print("error")
                    } else {
                        if recodeName == lastRecodeName {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name("UpdateFinish"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name("CheckFinish"), object: nil)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func cutString(str: String, start: Int, end: Int) -> String {
        var outputStr = ""
        
        let head = str.index(str.startIndex, offsetBy: start)
        let tail = str.index(str.startIndex, offsetBy: end)
        outputStr = String(str[head..<tail])
        
        return outputStr
    }
    
}
