//
//  ViewController.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/22.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit
import AudioToolbox

class ScanTicketViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var ticketNum: UILabel!
    @IBOutlet weak var ticketPeriod: UILabel!
    @IBOutlet weak var ticketDate: UILabel!
    @IBOutlet weak var ticketRandom: UILabel!
    @IBOutlet weak var ticketCost: UILabel!
    @IBOutlet weak var ticketSale: UILabel!
    
    let config = Config()
    let pubFunc = PubFunc()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var naviBar = UIView()
    var qrCodeFrameView = UIView()
    var switchButton = UIButton()
    var menuButton = UIButton()
    var isSwitch = false
    var userInformation = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInformation = UserDefaults.standard.dictionary(forKey: "UserInformation")!
        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(startScan), name: NSNotification.Name(rawValue: "StartScan"), object: nil)
        
        configurationScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        switchButton.setImage(UIImage(named: "Off"), for: .normal)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func configurationScanner() {
        let screenHeight = UIScreen.main.bounds.height
        
        naviBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/10)
        naviBar.backgroundColor = UIColor(red: 176/255, green: 217/255, blue: 226/255, alpha: 1.0)
        
        switchButton = UIButton(frame: CGRect(x: self.view.frame.width/2 - 50, y: self.view.frame.height/2 - 50, width: 100, height: 50))
        switchButton.setImage(UIImage(named: "Off"), for: .normal)
        switchButton.imageView?.contentMode = .scaleAspectFit
        switchButton.addTarget(self, action: #selector(lightSwitch), for: .touchUpInside)
        
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
        title.text = "掃描電子發票"
        
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            let input = try? AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input!)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.view.frame.height)/2)
            view.layer.addSublayer(videoPreviewLayer)
            
            settingScannerFrame()
            captureSession.startRunning()
        }
        
        view.addSubview(naviBar)
        view.addSubview(switchButton)
        view.addSubview(title)
        view.addSubview(menuButton)
    }
    
    func settingScannerFrame() {
        let qrCodeFrameView = self.qrCodeFrameView
        qrCodeFrameView.layer.borderWidth = 3
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
            if metadataObj.type == AVMetadataObject.ObjectType.qr {
                let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView.frame = barCodeObject!.bounds
                guard let value = metadataObj.stringValue else { return }
                let valueArry = value.split(separator: " ")
                let strA = valueArry[0]
                let checkStr = cutString(str: String(strA), start: 0, end: 1)
                guard let check_ascii = UnicodeScalar(checkStr)?.value else { return }
                if Int(check_ascii) >= 65 && Int(check_ascii) <= 90  {
                    qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                    
                    let numEn = cutString(str: String(strA), start: 0, end: 2)
                    let num = cutString(str: String(strA), start: 2, end: 10)
                    let y = cutString(str: String(strA), start: 10, end: 13)
                    let m = cutString(str: String(strA), start: 13, end: 15)
                    let d = cutString(str: String(strA), start: 15, end: 17)
                    let random = cutString(str: String(strA), start: 17, end: 21)
                    let cost = cutString(str: String(strA), start: 29, end: 37)
                    let cost_int = Int(cost, radix: 16)!
                    var sale = ""
                    if String(strA).count > 37 {
                        sale = cutString(str: String(strA), start: 45, end: 53)
                    }
                    let ticket = numEn+"-"+num
                    let date = String(Int(y)!+1911) + "-" + m + "-" + d
                    
                    var detailAry = [String:Any]()
                    detailAry["ticketNum"] = ticket
                    detailAry["date"] = date
                    detailAry["random"] = random
                    detailAry["cost"] = String(cost_int)
                    detailAry["sale"] = sale
                    detailAry["info"] = []
                    detailAry["check"] = "U"
                    captureSession.stopRunning()
                    showScanTicketResult(ticketDetail: detailAry)
                } else {
                    qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                }
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
    
    @objc func lightSwitch() {
        if isSwitch {
            isSwitch = false
            toggleTorch(on: false)
            switchButton.setImage(UIImage(named: "Off"), for: .normal)
        } else {
            isSwitch = true
            toggleTorch(on: true)
            switchButton.setImage(UIImage(named: "On"), for: .normal)
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                return
            }
        }
    }
    
    func dateTitle(month: String) -> String {
        var period = ""
        switch month {
        case "01","02":
            period = "01-02"
        case "03","04":
            period = "03-04"
        case "05","06":
            period = "05-06"
        case "07","08":
            period = "07-08"
        case "09","10":
            period = "09-10"
        case "11","12":
            period = "11-12"
        default:
            break
        }
        
        return period
    }
    
    func showScanTicketResult(ticketDetail: [String:Any]) {
        let date = ticketDetail["date"] as! String
        let dateAry = date.split(separator: "-")
        ticketNum.text = (ticketDetail["ticketNum"]! as! String)
        ticketPeriod.text = String(Int(String(dateAry[0]))! - 1911) + "年" + dateTitle(month: String(dateAry[1])) + "月"
        ticketDate.text = dateAry[0] + "-" + dateAry[1] + "-" + dateAry[2]
        ticketRandom.text = "隨機碼 : " + (ticketDetail["random"]! as! String)
        ticketCost.text = "總計 : " + (ticketDetail["cost"]! as! String)
        ticketSale.text = "賣方 : " + (ticketDetail["sale"]! as! String)
        saveScanTicket(detail: ticketDetail)
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
                    self.isSwitch = false
                    self.switchButton.setImage(UIImage(named: "Off"), for: .normal)
                    self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼儲存完成", loading: false, status: self.config.finish)
                }
            } else {
                DispatchQueue.main.async {
                    self.pubFunc.hitUser()
                    self.isSwitch = false
                    self.switchButton.setImage(UIImage(named: "Off"), for: .normal)
                    self.appDelegate.addSubView(self_view: self, showMessage: "發票號碼已存在", loading: false, status: self.config.warn)
                }
            }
        }
    }
    
    @objc func startScan() {
        qrCodeFrameView.layer.borderColor = UIColor.clear.cgColor
        captureSession.startRunning()
    }
    
    @objc func mainMenuAct() {
        dismiss(animated: true, completion: nil)
    }
    
}

