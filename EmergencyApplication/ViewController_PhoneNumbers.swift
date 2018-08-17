//
//  ViewController_PhoneNumbers.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 2/1/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI

class ViewController_PhoneNumbers: UIViewController, UITextFieldDelegate, CNContactPickerDelegate,UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate {
    
    //MARK: Outlets and Variables

    @IBOutlet var tblContacts: UITableView!    
    var tagOfSelectTextFeild = 0
    var arrAllContacts = [Dictionary <String, String>] () /* In order to add contact into Arr */
    var arrSendSms = [String]()
    var ContactDictionary = [String:String] ()

    @IBOutlet var txtFields: [UITextField]!
    
    var isFromRegister = false
    let userDefaults =  UserDefaults.standard

    
    override func viewDidLoad() {
        
   // print(objDB.getDatabaseFilePath())
    //MARK: Textfeild Delegate Methods
        
        super.viewDidLoad()
        AppDelegate.getAppDelegate().checkContactAuthorization()
        
        self.navigationController?.navigationItem.hidesBackButton = true
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(ViewController_PhoneNumbers.btnDonePressed))
        
        
        self.navigationItem.leftBarButtonItem = btnDone
        
        if(isFromRegister) {
            let alert = UIAlertController(title: "Phone Numbers", message: "Please set your emergency contacts", preferredStyle: .alert)
            
            let okButtun = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) -> Void in
                print("Okay button pressed")
                
            })
            
            alert.addAction(okButtun)
            present(alert, animated: true, completion: nil)
            

        }
        
        getEmergencyContacts()
        
    }
   
    func btnDonePressed(){
        
        let userId = UserDefaults.standard.value(forKey: "userId") as! String!

        
        let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/\(userId)/EmergencyContact"
        
        AppDelegate.getAppDelegate().showActivityIndicator()

        
        AppDelegate.getAppDelegate().callWebService(url, parameters: arrAllContacts as AnyObject, httpMethod: "POST", completion: { (result) -> Void in
            
            DispatchQueue.main.async { () -> Void in
                AppDelegate.getAppDelegate().hideActivityIndicator()
                
                if(self.arrSendSms.count > 0) {
                
                self.SendSms()
                
                }else{
                    
                    if(self.isFromRegister) {
                        self.isFromRegister = false
                        self.navigationController?.popToRootViewController(animated: false)
                        
                    }else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
//                if(self.isFromRegister) {
//                    self.isFromRegister = false
//                    
//                    self.navigationController?.popToRootViewControllerAnimated(false)
//                    
//                }else {
//                    self.navigationController?.popViewControllerAnimated(true)
//                    
//                }
            }
            },failure:{ (result) -> Void in
            
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
    
    
//        let userNumber = NSUserDefaults.standardUserDefaults().valueForKey("userId") as! Int
//        let flushDB = "delete from contacts where user_contact_no = '\(userNumber)'"
//        objDB.deleteQuery(flushDB)

//        if (arrAllContacts.count > 0) {
//            
//            for var dict:Dictionary <String, String> in arrAllContacts{
//                
//                let strType = dict["contact_type"] as String!
//                
//                let strNumber = dict["emergency_contact_no"] as String!
//                
//                let strName = dict["emergency_contact_name"] as String!
//                
//                let nsDefaults = dict["user_contact_no"] as String!
//                
//                let isAccepted = dict["is_accepted"] as String!
//                
//                let string = "insert into contacts (user_contact_no,emergency_contact_no,contact_type,emergency_contact_name,is_accepted) values ('\(nsDefaults)','\(strNumber)','\(strType)', '\(strName)', '\(isAccepted)')"
//                
//                objDB.insertQuery(string);
//            }
//            if(arrSendSms.count > 0) {
//                SendSms()
//                
//            }else{
//                if(self.isFromRegister) {
//                    self.isFromRegister = false
//                    self.navigationController?.popToRootViewControllerAnimated(false)
//                    
//                }else {
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//            }
//        }else{
//            if(self.isFromRegister) {
//                self.isFromRegister = false
//                self.navigationController?.popToRootViewControllerAnimated(false)
//                
//            }else {
//                self.navigationController?.popViewControllerAnimated(true)
//            }
//        }
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let  contactPickerViewController = CNContactPickerViewController ()
        contactPickerViewController.delegate = self
        tagOfSelectTextFeild = textField.tag
        present(contactPickerViewController, animated: true, completion: nil)
        return false
    }
    
    //MARK: Contact Selection Methods
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        navigationController?.popViewControllerAnimated(true)
        displayDataIntoField(contact)
    
    }
    
    
    func displayDataIntoField(_ arrData:CNContact) {
        
        
        if((arrData.phoneNumbers.last) != nil){
            
            let numbers:[CNLabeledValue] = arrData.phoneNumbers
            
            var arr = [Dictionary <String, String>] ()
            
            var dict = Dictionary <String, String>()
            
            if(numbers.count > 0){
                
                let strName:String = String(arrData.givenName) + " \(arrData.familyName)"
                
                var strLable:String = ""
                
                var strNumber:String = ""
                
                for number in numbers{
                    
                    if let str1 = number.value(forKey: "label"){
                        
                        strLable = String(describing: str1).replacingOccurrences(of: "_$!<", with: "").replacingOccurrences(of: ">!$_", with: "")
                    }
                    
                    if let str2 = ((number.value(forKey: "value")! as AnyObject).value(forKey: "digits")){
                        strNumber = String(describing: str2)
                    }
                    
                    dict["emergencyContactType"] = strLable
                    
                    dict["emergencyContactNo"] = strNumber
                    
                    dict["emergencyContactName"] = strName
                    
                    
                    //print(dictNumber);
                    
                    arr.append(dict)
                }
                
            }
            
            askUserForSelection(arr)
        }
    }
    
    func askUserForSelection(_ arrContacts:[Dictionary <String, String>]) {
        
        
        
        if(arrContacts.count > 0){
            
            let actionSheet = UIAlertController(title: "Select Number", message: "", preferredStyle: .actionSheet)
            
            for (var dict) in arrContacts{
                
                var strLabel:String = ""
                
                var strNumber:String = ""
                
                if let key =  dict["emergencyContactType"]{
                    strLabel = key
                }
                
                if let value = dict["emergencyContactNo"]{
                    strNumber = value
                }
                let UserContactNo = UserDefaults.standard.value(forKey: "userContactNo") as! String!
                
                let userName = UserDefaults.standard.value(forKey: "userName") as! String!
                
                dict["userContactNo"] = UserContactNo
                
                dict["userName"] = userName
                
                dict["accepted"] = "0"
                
                let somethingAction = UIAlertAction(title: "\(strLabel) - \(strNumber)", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                    
                    
                    let isPresent =  self.arrAllContacts.contains(where: { (element) -> Bool in
                        
                        return (element as [String:String] == dict)
                    })
                    
                    if(!isPresent as Bool){
                        self.arrAllContacts.append(dict);
                        
                        self.arrSendSms.append(dict["emergencyContactNo"] as String!)
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.tblContacts.reloadData()
                        })
                        
                    }else{
                                let alert = UIAlertController(title: "", message: "Same Emergency contact already exist in the list", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let alertActionOk = UIAlertAction(title: "Ok", style: .default, handler: { void in
                                    
                                });
                                
                                alert.addAction(alertActionOk)
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        })
                        
                        actionSheet.addAction(somethingAction)
                    }

            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in
                print("cancel")})
            
            actionSheet.addAction(cancelAction)
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.present(actionSheet, animated: true, completion: nil)
            })
        }
    }
    
    //MARK: Table view Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrAllContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifierCell")! as UITableViewCell
        
        var dict = arrAllContacts[indexPath.row]
        
        cell.textLabel?.text = dict["emergencyContactName"]
        
        cell.detailTextLabel?.text = dict["emergencyContactNo"]
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let dict = arrAllContacts[indexPath.row] as Dictionary<String, String>
            if(arrSendSms.contains(arrAllContacts[indexPath.row]["emergencyContactNo"] as String!)) {
                
                arrSendSms.remove(at: arrSendSms.index(of: arrAllContacts[indexPath.row]["emergencyContactNo"] as String!)!)
            }
            
            arrAllContacts.remove(at: indexPath.row)
            
//            let deleteContact = dict["emergency_contact_no"] as String!
    
            self.tblContacts.reloadData()
           print(arrAllContacts)
        }
    }
    
    @IBAction func btnActnAddContact(_ sender: UIBarButtonItem) {
        let  contactPickerViewController = CNContactPickerViewController ()
        contactPickerViewController.delegate = self
        
        present(contactPickerViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSaveContact(_ sender: AnyObject) {
        
        for TF in txtFields{
            
            ContactDictionary["contact\(TF.tag)"] = TF.text;
        }
        print(ContactDictionary)
    }

    
    // MARK: Database Methods
    
    
    func getEmergencyContacts() {
        let userId = UserDefaults.standard.value(forKey: "userId") as! String
//        let string = "select * from contacts where user_contact_no = '\(nsDefaults)'"
//        arrAllContacts = objDB.selectQuery(string)
        let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/\(userId)/EmergencyContact"
        AppDelegate.getAppDelegate().callWebService(url, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in
            
            self.parseResponce(result as! [[String : AnyObject]])
            
            if(self.arrAllContacts.count > 0) {
                DispatchQueue.main.async { () -> Void in
                    self.tblContacts.reloadData()
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
                    
                }
        })


    
    }
    
    //MARK: SMS messages
    
    func SendSms() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((__int64_t)(0.5)) / Double(NSEC_PER_SEC), execute: {
            let userName = UserDefaults.standard.value(forKey: "userName") as! String!
            
            let messageVC = MFMessageComposeViewController()
            
            messageVC.messageComposeDelegate = self;
            
            messageVC.recipients = self.arrSendSms
            
            messageVC.body = "\(userName) has added you as an emergrency contact. Please download this app to know when \(userName) is need of your help. https://appsto.re/us/uhIKcb.i";
            
            self.present(messageVC, animated: true, completion: nil)
        })
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
        
        if(self.isFromRegister) {
            self.isFromRegister = false
            self.navigationController?.popToRootViewController(animated: false)
            
        }else {
            self.navigationController?.popViewController(animated: true)
        }
        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            switch (result.rawValue) {
//            case MessageComposeResultCancelled.rawValue:
//                print("Message was cancelled")
//                self.dismissViewControllerAnimated(true, completion: nil)
//                
//                if(self.isFromRegister) {
//                    self.isFromRegister = false
//                    self.navigationController?.popToRootViewControllerAnimated(false)
//                    
//                }else {
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//            case MessageComposeResultFailed.rawValue:
//                print("Message failed")
//                self.dismissViewControllerAnimated(true, completion: nil)
//                
//                if(self.isFromRegister) {
//                    self.isFromRegister = false
//                    self.navigationController?.popToRootViewControllerAnimated(false)
//                    
//                }else {
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//                
//            case MessageComposeResultSent.rawValue:
//                print("Message was sent")
//                self.dismissViewControllerAnimated(true, completion: nil)
//                if(self.isFromRegister) {
//                    self.isFromRegister = false
//                    self.navigationController?.popToRootViewControllerAnimated(false)
//                    
//                }else {
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//            default: break
//                
//            }
//        })
    }
    
    func parseResponce(_ responce : [[String:AnyObject]]) {
        
        for dict in responce {
            var localDict = [String:String] ()
            
            for(key,value) in dict {
                localDict[key] = "\(value)"
            }
            arrAllContacts.append(localDict)
        }
            }
            
}
    

