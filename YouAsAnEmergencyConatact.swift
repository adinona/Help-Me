//
//  YouAsAnEmergencyConatact.swift
//  HelpMe
//
//  Created by Aditya  Bhandari on 5/15/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//


    import UIKit
    import ContactsUI

    class YouAsAnEmergencyContact: UIViewController, UITextFieldDelegate, CNContactPickerDelegate,UITableViewDataSource,UITableViewDelegate {
        
        //MARK: Outlets and Variables
        
        @IBOutlet var tblContacts: UITableView!
        
        var tagOfSelectTextFeild = 0
        var arrAllContacts = [Dictionary <String, String>] () /* In order to add contact into Arr */
        var arrSendSms = [String]()
        var ContactDictionary = [String:String] ()
        
        @IBOutlet var txtFields: [UITextField]!
        
        let objDB = Database.sharedDatabaseInstance.sharedInstance
        var isFromRegister = false
        let userDefaults =  NSUserDefaults.standardUserDefaults()
        
        
        override func viewDidLoad() {
            
            print(objDB.getDatabaseFilePath())
            //MARK: Textfeild Delegate Methods
            
            super.viewDidLoad()
            AppDelegate.getAppDelegate().checkContactAuthorization()
            
            self.navigationController?.navigationItem.hidesBackButton = true
            
            let btnDone = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(ViewController_PhoneNumbers.btnDonePressed))
            
            
            self.navigationItem.leftBarButtonItem = btnDone
            
            if(isFromRegister) {
                let alert = UIAlertController(title: "Phone Numbers", message: "Please set your emergency contacts", preferredStyle: .Alert)
                
                let okButtun = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
                    print("Okay button pressed")
                    
                })
                
                alert.addAction(okButtun)
                presentViewController(alert, animated: true, completion: nil)
                
                
            }
            
            getEmergencyContacts()
            
        }
        
        func btnDonePressed(){
            
            let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") as! String!
            
            
            let url = "http://107.196.101.242:8181/EmergencyApp/webapi/users/\(userId)/EmergencyContact"
            
            
            if (arrAllContacts.count > 0) {
                
                AppDelegate.getAppDelegate().callWebService(url, parameters: arrAllContacts, httpMethod: "POST", completion: { (result) -> Void in
                    if(self.isFromRegister) {
                        self.isFromRegister = false
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }else {
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                    }, failure: { (result) -> Void in
                        let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .Alert)
                        
                        let okButtun = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
                            print("Okay button pressed")
                            
                        })
                        
                        alert.addAction(okButtun)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        }
                })
                
            }
            
           
        }
        
        
        func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
            let  contactPickerViewController = CNContactPickerViewController ()
            contactPickerViewController.delegate = self
            tagOfSelectTextFeild = textField.tag
            presentViewController(contactPickerViewController, animated: true, completion: nil)
            return false
        }
        
        //MARK: Contact Selection Methods
        
        func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
            //        navigationController?.popViewControllerAnimated(true)
            displayDataIntoField(contact)
            
        }
        
        
        func displayDataIntoField(arrData:CNContact) {
            
            
            if((arrData.phoneNumbers.last) != nil){
                
                let numbers:[CNLabeledValue] = arrData.phoneNumbers
                
                var arr = [Dictionary <String, String>] ()
                
                var dict = Dictionary <String, String>()
                
                if(numbers.count > 0){
                    
                    let strName:String = String(arrData.givenName).stringByAppendingString(" \(arrData.familyName)")
                    
                    var strLable:String = ""
                    
                    var strNumber:String = ""
                    
                    for number in numbers{
                        
                        if let str1 = number.valueForKey("label"){
                            
                            strLable = String(str1).stringByReplacingOccurrencesOfString("_$!<", withString: "").stringByReplacingOccurrencesOfString(">!$_", withString: "")
                        }
                        
                        if let str2 = (number.valueForKey("value")!.valueForKey("digits")){
                            strNumber = String(str2)
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
        
        func askUserForSelection(arrContacts:[Dictionary <String, String>]) {
            
            
            
            if(arrContacts.count > 0){
                
                let actionSheet = UIAlertController(title: "Select Number", message: "", preferredStyle: .ActionSheet)
                
                for (var dict) in arrContacts{
                    
                    var strLabel:String = ""
                    
                    var strNumber:String = ""
                    
                    if let key =  dict["emergencyContactType"]{
                        strLabel = key
                    }
                    
                    if let value = dict["emergencyContactNo"]{
                        strNumber = value
                    }
                    let UserContactNo = NSUserDefaults.standardUserDefaults().valueForKey("userContactNo") as! String!
                    
                    let userName = NSUserDefaults.standardUserDefaults().valueForKey("userName") as! String!
                    
                    dict["userContactNo"] = UserContactNo
                    
                    dict["userName"] = userName
                    
                    dict["accepted"] = "0"
                    
                    let somethingAction = UIAlertAction(title: "\(strLabel) - \(strNumber)", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                        
                        
                        let isPresent =  self.arrAllContacts.contains({ (element) -> Bool in
                            
                            return (element as [String:String] == dict)
                        })
                        
                        if(!isPresent as Bool){
                            self.arrAllContacts.append(dict);
                            
                            self.arrSendSms.append(dict["emergencyContactNo"] as String!)
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tblContacts.reloadData()
                            })
                            
                        }else{
                            let alert = UIAlertController(title: "", message: "Same Emergency contact already exist in the list", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                                
                            });
                            
                            alert.addAction(alertActionOk)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        
                    })
                    
                    actionSheet.addAction(somethingAction)
                }
                
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in
                    print("cancel")})
                
                actionSheet.addAction(cancelAction)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentViewController(actionSheet, animated: true, completion: nil)
                })
            }
        }
        
        //MARK: Table view Datasource Methods
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return arrAllContacts.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("identifierCell")! as UITableViewCell
            
            var dict = arrAllContacts[indexPath.row]
            
            cell.textLabel?.text = dict["emergencyContactName"]
            
            cell.detailTextLabel?.text = dict["emergencyContactNo"]
            
            return cell
        }
        func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
            
            return true
        }
        
        func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            if (editingStyle == UITableViewCellEditingStyle.Delete) {
                
                let dict = arrAllContacts[indexPath.row] as Dictionary<String, String>
                
                let deleteContact = dict["emergency_contact_no"] as String!
                
                
                let string = "delete from contacts where emergency_contact_no = '\(deleteContact)'"
                objDB.deleteQuery(string)
                arrAllContacts.removeAtIndex(indexPath.row)
                self.tblContacts.reloadData()
                print(arrAllContacts)
            }
        }
        

        
        
        // MARK: Database Methods
        
        
        func getEmergencyContacts() {
            let userId = NSUserDefaults.standardUserDefaults().valueForKey("userId") as! String
            //        let string = "select * from contacts where user_contact_no = '\(nsDefaults)'"
            //        arrAllContacts = objDB.selectQuery(string)
            let url = "http://107.196.101.242:8181/EmergencyApp/webapi/users/\(userId)/EmergencyContact"
            AppDelegate.getAppDelegate().callWebService(url, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in
                
                self.parseResponce(result as! [[String : AnyObject]])
                
                if(self.arrAllContacts.count > 0) {
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.tblContacts.reloadData()
                    }
                }
                
                
                }, failure: { (result) -> Void in
                    let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: .Alert)
                    
                    let okButtun = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) -> Void in
                        print("Okay button pressed")
                        
                    })
                    
                    alert.addAction(okButtun)
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
            })
            
            
            
        }
        
        
        
        func parseResponce(responce : [[String:AnyObject]]) {
            
            for dict in responce {
                var localDict = [String:String] ()
                
                for(key,value) in dict {
                    localDict[key] = "\(value)"
                }
                arrAllContacts.append(localDict)
            }
        }
        
    }
    
    


