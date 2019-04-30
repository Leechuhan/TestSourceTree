//
//  AppDelegate.swift
//  ScanTicket
//
//  Created by Louis on 2019/3/22.
//  Copyright © 2019 louis. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let pubFunc = PubFunc()
    var timer = Timer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        checkHadLogin()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)){
            print(userInfo)
            return
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        UserDefaults(suiteName: "group.net.pixnet.leechuhan.scanticket.BarcodeWidget")?.setValue("/P6ITYN2", forKey: "UserBarcode")
//        if let _ = UserDefaults.standard.object(forKey: "Version") {
//
//        } else {
//            NotificationCenter.default.post(name: NSNotification.Name("Update"), object: nil)
//        }
//
        let iCloudStatus = pubFunc.check_iCloud_status()
        if !iCloudStatus && UserDefaults.standard.dictionary(forKey: "UserInformation") != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            self.window?.rootViewController = homeViewController
            self.window?.makeKeyAndVisible()
        }
        AppEventsLogger.activate(application)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScanTicket")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func checkHadLogin() {
        if let _ = UserDefaults.standard.dictionary(forKey: "UserInformation") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
            self.window?.rootViewController = homeViewController
            self.window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = loginViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func addSubView(self_view: UIViewController, showMessage: String, loading: Bool, status: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loadingViewController = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        loadingViewController.message = showMessage
        loadingViewController.isLoading = loading
        loadingViewController.showImg = UIImage(named: status)!
        self_view.addChild(loadingViewController)
        self_view.view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self_view)
        if !loading {
            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
                self.removeSubView(self_view: self_view)
                NotificationCenter.default.post(name: NSNotification.Name("StartScan"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("ReturnDefault"), object: nil)
            })
        }
    }
    
    func removeSubView(self_view: UIViewController) {
        if self_view.children.count > 0 {
            let loadingViewController = self_view.children.last!
            loadingViewController.view.removeFromSuperview()
            loadingViewController.removeFromParent()
        }
    }

}

