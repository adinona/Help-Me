 //
//  LogInViewController.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 3/16/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var txtfldPassword: UITextField!
    @IBOutlet var txtfldPhoneNumber: UITextField!
    
    @IBOutlet var scrollLogin: UIScrollView!
    
    override func viewDidLoad() {
        
        // Ask for Authorisation from the User.
        super.viewDidLoad()
        
        self.title = "Log-In"
        txtfldPassword.underlined()
        txtfldPhoneNumber.underlined()
        
        
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        let Default = UserDefaults.standard
        if ((Default.object(forKey: "userContactNo") as AnyObject).length == 10) {
            AppDelegate.getAppDelegate().registerForGCM()
            performSegue(withIdentifier: "segueHome", sender: self)
        }
        txtfldPassword.text = nil
        txtfldPhoneNumber.text = nil
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtfldPassword.resignFirstResponder()
        txtfldPhoneNumber.resignFirstResponder()
        return true
    }
    
   
    
    
    @IBAction func btnLogIn(_ sender: AnyObject) {
        
        AppDelegate.getAppDelegate().showActivityIndicator()
        
        let strPhoneNumber = txtfldPhoneNumber.text as String!
        let strPassword = txtfldPassword.text as String!
        
        let is_URL: String = "http://188.166.227.51:8080/EmergencyApp/webapi/users/login?contactNo=\(strPhoneNumber)&password=\(strPassword)"
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in

            DispatchQueue.main.async { () -> Void in
                
                AppDelegate.getAppDelegate().hideActivityIndicator()
                
                let strFirstName = result["fname"] as! String!
                
                let strLastName = result["lname"] as! String!
                
                let fullName = strFirstName! + " " + strLastName!
                
                let UserId = "\(result["id"] as! Int!)"
                
                let UserContactNo = "\(result["contactNo"] as! Int!)"
                
                let userDefaults =  UserDefaults.standard
                
                userDefaults.set(UserId, forKey: "userId")
                
                userDefaults.set(fullName, forKey: "userName")
                
                userDefaults.set(UserContactNo, forKey: "userContactNo")
                
                AppDelegate.getAppDelegate().registerForGCM()
                
                
                self.performSegue(withIdentifier: "segueHome", sender: self)
                
            }
            
            
            }, failure:{ (result) -> Void in
                
                DispatchQueue.main.async { () -> Void in
                    
                    AppDelegate.getAppDelegate().hideActivityIndicator()
                    let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .alert)
                    
                    let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                        print("Okay button pressed")
                        
                    })
                    alert.addAction(okButtun)
                    DispatchQueue.main.async { () -> Void in
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        })
    }
    
    
func getLogInFromDataBase() {
        //DATABASE
        //        let strPhoneNumber = txtfldPhoneNumber.text as String!
        //        let strPassword = txtfldPassword.text as String!
        //
        //
        //        let string = "select phone_number,password,first_name,last_name from UserInfo where phone_number = '\(txtfldPhoneNumber.text as String!)'"
        //
        //        let contactArray = objDb.selectQuery(string)
        //
        //
        //        if (contactArray.count > 0) {
        //            for (var dict) in contactArray{
        //                if(dict["phone_number" as String!] == strPhoneNumber && dict["password" as String!] == strPassword) {
        //
        //                    let strFirstName = dict["first_name"] as String!
        //
        //                    let strLastName = dict["last_name"] as String!
        //
        //                    let userDefaults =  NSUserDefaults.standardUserDefaults()
        //
        //                    userDefaults.setObject("\(strPhoneNumber)", forKey: "userId")
        //                    userDefaults.setObject("\(strFirstName) \(strLastName))", forKey: "userName")
        //                    performSegueWithIdentifier("segueHome", sender: self)
        //
        //                } else {
        //                    let alert = UIAlertController(title: "Error", message: "Invalid credentials", preferredStyle: .Alert)
        //
        //                    let okButtun = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
        //                        print("Okay button pressed")
        //
        //                    })
        //
        //                    alert.addAction(okButtun)
        //                    presentViewController(alert, animated: true, completion: nil)
        //                }
        //
        //            }
        //
        //        } else {
        //            let alert = UIAlertController(title: "Error", message: "User Does Not Exist", preferredStyle: .Alert)
        //
        //            let okButtun = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
        //                print("Okay button pressed")
        //
        //            })
        //
        //            alert.addAction(okButtun)
        //            presentViewController(alert, animated: true, completion: nil)
        //
        
    }
    @IBAction func btnSignUp(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "segueSignUp", sender: self)
    }
}
