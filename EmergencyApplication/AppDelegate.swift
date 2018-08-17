//
//  AppDelegate.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 1/11/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit
import Contacts
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate, CLLocationManagerDelegate {

    var  viewActivity: UIView?
    var indicator: UIActivityIndicatorView?
    var window: UIWindow?
    var contacts = CNContactStore()
    var isAccessGranted:Bool = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onEmergencyOccurence(_:)) , name: NSNotification.Name(rawValue: "onMessageRecieved"), object: nil)

        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(remoteNotification, forKey: "remoteNotification")
            
            userDefaults.set(true, forKey: "isRemoteNotificationAvailible")
        }
        
        
        // Override point for customization after application launch.
        
        
        //print(objDB.getDatabaseFilePath())
        
       // objDB.createDatabaseIfNotExist()
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        
        application.registerForRemoteNotifications()
        
        let gcmConfig = GCMConfig.default()
        
        gcmConfig?.receiverDelegate = self
        
        GCMService.sharedInstance().start(with: gcmConfig)

        return true
    }
    
    
    func callWebService(_ url: String, parameters: AnyObject?, httpMethod: String, completion: @escaping (_ result: AnyObject) -> Void, failure: @escaping (_ result: AnyObject) -> Void) {
        
        let url =  URL(string:url) as URL!
        
        let urlObj = NSMutableURLRequest(url:url!)
        
        urlObj.httpMethod = httpMethod
        
        urlObj.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if(parameters != nil){
            
            do {
                urlObj.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: JSONSerialization.WritingOptions.prettyPrinted)
            }
            catch {
                print("Error")
            }
            
            
        }
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: urlObj, completionHandler: { (data, response, error) -> Void in
            
            guard let aData = data, let aResponse = response as? HTTPURLResponse
                else{
                    print("Something went wrong")
                    return
            }
            switch(aResponse.statusCode) {
            case 200:
                do{
                    let returnData = try JSONSerialization.jsonObject(with: aData, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(returnData)
                    
                    completion(result: returnData)
                }
                catch {
                    print("Error")
                }
                
            default:
                
                do{
                    let returnData = try JSONSerialization.jsonObject(with: aData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:AnyObject]
                    print(returnData)
                    failure(result: returnData)
                }
                catch {
                    print("Error")
                }
            }
        }) 
        task.resume()
        
    }
    func onEmergencyOccurence (_ notification: Notification) {
        
        
        
          let VCs = (self.window?.rootViewController!.childViewControllers)!
        
        if !VCs.last!.isKind(of: EmergencyLocation.self) {
            
            let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let objVS:EmergencyLocation = story.instantiateViewController(withIdentifier: "emergercyLocation") as! EmergencyLocation
            
            objVS.dict = notification.userInfo! as [NSObject : AnyObject]
            
            self.window?.rootViewController?.navigationController?.pushViewController(objVS, animated: true)
            
        }
            
        
        
    }
    


    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UIApplication.shared.applicationIconBadgeNumber = 1
        UIApplication.shared.applicationIconBadgeNumber = 0


    
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    class func getAppDelegate()  -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func checkContactAuthorization () {
        
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch status {
        case .authorized:
            isAccessGranted = true
            print("Access Granted")
        case .denied, .notDetermined:
            
            contacts.requestAccess(for: CNEntityType.contacts, completionHandler: { (access,err) -> Void in
                if(access) {
                    self.isAccessGranted = true
                    print("Access Granted")
                } else {
                    if status == CNAuthorizationStatus.denied{
                        self.isAccessGranted = false
                        print("Access Denied")
                    }
                }
            })
        default:
            isAccessGranted = false
        }
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data ) {
        // [END receive_apns_token]
        // [START get_gcm_reg_token]
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.default()
        instanceIDConfig?.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().start(with: instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken as AnyObject,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true as AnyObject]
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler as! GGLInstanceIDTokenHandler)
        // [END get_gcm_reg_token]
    }
    
    func application( _ application: UIApplication,
                      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                                                   fetchCompletionHandler handler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // [START_EXCLUDE]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onMessageRecieved"), object: nil, userInfo: userInfo)
        handler(UIBackgroundFetchResult.newData);
        // [END_EXCLUDE]
    }
    
    
    func registrationHandler(_ registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            UserDefaults.standard.setValue(registrationToken, forKey: "regToken")
            let userInfo = ["registrationToken": registrationToken]
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
        }
    }

    
    
    func checkLocationService() -> Bool  {
        
        var status:Bool = false
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                status = false
            case .restricted:
                status = false
            case .denied:
                status = false
            case .authorizedAlways,.authorizedWhenInUse:
                status = true
            }
            
        }
                return status

    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().token(withAuthorizedEntity: gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler as! GGLInstanceIDTokenHandler)
    }
    
    
    func registerForGCM() -> Void {
        
        let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/GcmRegister"
        
        var dict = [String:String] ()
        
        dict["registrationId"] = UserDefaults.standard.value(forKey: "regToken") as? String
        dict["contactNo"] = UserDefaults.standard.value(forKey: "userContactNo") as? String
        
        callWebService(url, parameters: dict as AnyObject, httpMethod: "Post", completion: { (result) in
            if(result["message"] as! String == "Successfull !!!") {
                print(result["message"])
            } else {
                let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                DispatchQueue.main.async { () -> Void in
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
            }, failure: { (result) -> Void in
                let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                DispatchQueue.main.async { () -> Void in
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                }
                
        })

        
    }
    
    
    func unregisterForGCM() -> Void {
        
        let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/GcmUnRegister"
        
        var dict = [String:String] ()
        
        dict["registrationId"] = UserDefaults.standard.value(forKey: "regToken") as? String
        dict["contactNo"] = UserDefaults.standard.value(forKey: "userContactNo") as? String
        
        callWebService(url, parameters: dict as AnyObject, httpMethod: "Post", completion: { (result) in
            
            if(result["message"] as! String == "Successfull !!!") {
                print(result["message"])
            } else {
                let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                DispatchQueue.main.async { () -> Void in
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
            }, failure: { (result) -> Void in
                let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                DispatchQueue.main.async { () -> Void in
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                }
        })
    }
    
    func showActivityIndicator() {
        
        if((viewActivity == nil)){
            viewActivity = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            viewActivity?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            indicator?.startAnimating()
            
            let lbl:UILabel = UILabel(frame: CGRect(x: 3, y: 0, width: (viewActivity?.frame.size.width)! - 6, height: 30))
            lbl.numberOfLines = 0
            lbl.backgroundColor = UIColor.clear
            lbl.textColor = UIColor.white
            lbl.font = UIFont(name: "HelveticaNeue", size: 15.0)
            lbl.textAlignment = NSTextAlignment.center
            lbl.text = "Loading..."
            
            indicator!.center = CGPoint(x: (viewActivity?.center.x)!, y: (viewActivity?.center.y)! - ((indicator?.frame.size.height)! / 4))
            
            lbl.center = CGPoint(x: (viewActivity?.center.x)!, y: (indicator?.frame)!.maxY + ((indicator?.frame.size.height)! / 4))
            
            viewActivity?.addSubview(lbl)
        }else{
            indicator?.center = (viewActivity?.center)!
        }
        
        viewActivity?.addSubview(indicator!)
        viewActivity?.layer.cornerRadius = 10
        viewActivity?.center = (self.window?.center)!
        
        self.window?.addSubview(viewActivity!)
    }
    
    func hideActivityIndicator(){
        if(viewActivity != nil){
            indicator?.stopAnimating()
            viewActivity?.removeFromSuperview()
            indicator = nil
            viewActivity = nil
        }
    }

    
    
}

