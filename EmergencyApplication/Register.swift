//
//  Register.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 3/28/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//
import UIKit

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var txtfldCheckPassword: UITextField!
    @IBOutlet var txtfldPassword: UITextField!
    @IBOutlet var txtfldFirstName: UITextField!
    @IBOutlet var txtfldPhoneNumber: UITextField!
    @IBOutlet var txtfldLastName: UITextField!
    
    let getData = "Select phone_number from UserInfo"

    
    var RegisterInfo = [Dictionary <String, String>] () /* In order to add contact into Arr */

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {// called when 'return' key pressed. return NO to ignore.


        
        txtfldLastName.resignFirstResponder()
        txtfldPassword.resignFirstResponder()
        txtfldFirstName.resignFirstResponder()
        txtfldPhoneNumber.resignFirstResponder()
        txtfldCheckPassword.resignFirstResponder()

        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
// For Web Service
    /*
     POST
     URL : http://107.196.101.242:8181/EmergencyApp/webapi/users
     Request Body:{
     "contactNo": 4092345335,
     "fname": "Adi",
     "lname": "Tanna",
     "password": "test"

 */
//
    func registerUser() {
        
        AppDelegate.getAppDelegate().showActivityIndicator()
        
        var dict = [String:String] ()
        
        dict["contactNo"] = txtfldPhoneNumber.text as String!
        
        dict["fname"] = txtfldFirstName.text as String!
        
        dict["lname"] = txtfldLastName.text as String!
        
        dict["password"] = txtfldPassword.text as String!
        
        let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users"
        
        AppDelegate.getAppDelegate().callWebService(url, parameters: dict as AnyObject, httpMethod: "POST", completion: { (result) -> Void in
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
            
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "segueNumber", sender: self)
                AppDelegate.getAppDelegate().hideActivityIndicator()
            }
        },
        failure:{ (result) -> Void in
            
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
        
        
        
//
//        let urlObj = NSMutableURLRequest(URL:url)
//
//        urlObj.HTTPMethod = "POST"
//        
//        urlObj.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        do {
//            urlObj.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
//        }
//        catch {
//            print("Error")
//        }
//        let urlSession = NSURLSession.sharedSession()
//        
//        let task = urlSession.dataTaskWithRequest(urlObj) { (data, response, error) in
//            
//            guard let aData = data, aResponse = response
//                else{
//                    print("Something went wrong")
//                    return
//            }
//            do{
//                let returnData = try NSJSONSerialization.JSONObjectWithData(aData, options: NSJSONReadingOptions.MutableLeaves) as! [String:AnyObject]
//            print(returnData)
//            }
//            catch {
//                print("Error")
//            }
//        }
//        task.resume()
    }
    

    @IBAction func btnRegister(_ sender: AnyObject) {
        
        
        if(txtfldPhoneNumber.text?.characters.count != 10){
            let alert = UIAlertController(title: "Error", message: "Invalid Number", preferredStyle: .alert)
            
            let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                print("Okay button pressed")
                
            })
            
            alert.addAction(okButtun)
            present(alert, animated: true, completion: nil)
        } else {
            
            if(txtfldPassword.text as String! == txtfldCheckPassword.text as String!) {
              
                registerUser()

            }else{
                let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: .alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                present(alert, animated: true, completion: nil)

            }
            
         

        }
        
      

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueNumber") {
            let objPhoneNumbers = segue.destination as! ViewController_PhoneNumbers
            objPhoneNumbers.isFromRegister = true
        }
    }
    
}

