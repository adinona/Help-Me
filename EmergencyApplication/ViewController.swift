//
//  ViewController.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 1/11/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MessageUI

//segueSignUp


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MFMessageComposeViewControllerDelegate, MenuDrawerDelegate {
    
    let userNumber = UserDefaults.standard.value(forKey: "userContactNo") as! String
    var arrSendSms = [String]()
    var timer:Timer?
    
    @IBOutlet var vwMenueDrawer: MenuDrawer!

    let locationManager = CLLocationManager()
    var coord: CLLocationCoordinate2D!
    @IBOutlet weak var Map: MKMapView!
   // let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    // MARK: VIEW LIFE CYCLE METHODS
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onEmergencyOccurence(_:)) , name: NSNotification.Name(rawValue: "onMessageRecieved"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appEntersForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        vwMenueDrawer.isHidden = false
        
        vwMenueDrawer.delegate = self
        
        btnDemo.layer.cornerRadius = btnDemo.frame.size.width/2
        
        let MenueButton = vwMenueDrawer.addSlideMenuButton() as UIBarButtonItem!
        
        self.navigationItem.leftBarButtonItem = MenueButton
        
        self.navigationController?.navigationItem.hidesBackButton = true
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        Map.showsUserLocation = true
        
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.vwMenueDrawer.btnMenu != nil {
            vwMenueDrawer.onSlideMenuButtonPressed(vwMenueDrawer.btnMenu!)
        }
        
    }
    
    func onEmergencyOccurence (_ notification: Notification) {
        
        
        let VCs = (self.navigationController!.childViewControllers) as [UIViewController]
        
        if !VCs.last!.isKind(of: EmergencyLocation.self) {
            
            let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let objVS:EmergencyLocation = story.instantiateViewController(withIdentifier: "emergercyLocation") as! EmergencyLocation
            
            objVS.dict = notification.userInfo! as [NSObject : AnyObject]
            
            self.navigationController?.pushViewController(objVS, animated: true)
            
            
        }
        
        
    }
    
    func appEntersForeground (_ notification:Notification) {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            Map.showsUserLocation = true

            
        }
    }
    
    
    func selectIndexInMenu(_ index : Int32) {
        
        DispatchQueue.main.async { () -> Void in
            self.vwMenueDrawer.onSlideMenuButtonPressed(self.vwMenueDrawer.btnMenu!)
        }
        if(index == 3){
            vwMenueDrawer.isHidden = true
        }
        
        switch(index)
        {
        case 0:
            performSegue(withIdentifier: "VCtoPN", sender: self)
        case 1:
            performSegue(withIdentifier: "VCtoEC", sender: self)

        case 2:
            btnLogOut(self)

        default:
            break
        }}
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        
    }// Called when the view is about to made visible. Default does nothing
    override func viewDidAppear(_ animated: Bool){
        
    }// Called when the view has been fully transitioned onto the screen. Default does notoverride hing
    override func viewWillDisappear(_ animated: Bool){
        
    }
    override func viewDidDisappear(_ animated: Bool){
        
    }
    
    //MARK: Location manager methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coord = manager.location!.coordinate
        let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.Map.setRegion(region, animated: true)
        
    }
    
    //MARK: Sms methods
    
    @IBOutlet var btnDemo: UIButton!
  
    @IBAction func SendSms(_ sender: UIButton) {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            Map.showsUserLocation = true
            
            
        }
        
        if AppDelegate.getAppDelegate().checkLocationService() {
            
            if sender.isSelected {
                timer?.invalidate()
                sender.isSelected = false
                
            }else{
                
                self.locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                Map.showsUserLocation = true
                
                sender.isSelected = true
                
                declareEmergency()
                
                timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(ViewController.declareEmergency), userInfo: nil, repeats: true)
            }
        } else {
            
            let alert = UIAlertController(title: "Location Services Disabled", message: "Location services Disabled", preferredStyle: .alert)
            
            let settings = UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
                print("Okay button pressed")
                UIApplication.shared.openURL(URL(string: "prefs:root=Privacy&path=LOCATION")!)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                print("Okay button pressed")
                
            })

            
            alert.addAction(settings)
            alert.addAction(cancel)
            DispatchQueue.main.async { () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }

    
        func declareEmergency() {
            
            
            let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/DeclareEmergency"
            
            var dict = [String:String]()
            
            dict["userName"] = UserDefaults.standard.value(forKey: "userName") as? String
            dict["contactNo"] = UserDefaults.standard.value(forKey: "userContactNo") as? String
            dict["latitude"] = "\(coord.latitude)"
            dict["longitude"] = "\(coord.longitude)"

            AppDelegate.getAppDelegate().callWebService(url, parameters: dict as AnyObject, httpMethod: "Post", completion: { (result) in
               
                if(result["message"] as! String == "Successfull !!!") {
                    print(result["message"])
                } else {
                    let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                    
                    let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                        print("Okay button pressed")
                        
                    })
                    
                    alert.addAction(okButtun)
                    DispatchQueue.main.async { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                }, failure: { (result) -> Void in
                    let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                    
                    let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                        print("Okay button pressed")
                        
                    })
                    
                    alert.addAction(okButtun)
                    DispatchQueue.main.async { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                        AppDelegate.getAppDelegate().hideActivityIndicator()

                        
                    }
                    
            })
        }
        

//        if sender.selected {
//            
//            sender.selected = false
//            
//        }else{
//            
//            sender.selected = true
//            
//            arrSendSms.removeAll()
//            
//            let messageVC = MFMessageComposeViewController()
//            
//            messageVC.body = "http://maps.apple.com/?q=\(coord.latitude),\(coord.longitude)"
//            
//            let string = "select emergency_contact_no from contacts where user_contact_no = '\(userNumber)'"
//            
//            let arrContacts = objDB.selectQuery(string)
//            
//            for var dict in arrContacts{
//                arrSendSms.append(dict["emergency_contact_no"]! as String)
//            }
//        
//            messageVC.recipients = arrSendSms
//            
//            messageVC.messageComposeDelegate = self;
//            
//            self.presentViewController(messageVC, animated: false, completion: nil)
//        }
//        
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
    //MARK: Other Methods
    @IBAction func btnLogOut(_ sender: AnyObject) {
        
        AppDelegate.getAppDelegate().unregisterForGCM()
        UserDefaults.standard.setValue(nil, forKey: "userId")
        UserDefaults.standard.setValue(nil, forKey: "userContactNo")
        UserDefaults.standard.setValue(nil, forKey: "userName")

        navigationController?.popToRootViewController(animated: true)
        
    
    }
}

