//
//  ViewControllerYourEC.swift
//  HelpMe
//
//  Created by Aditya  Bhandari on 5/16/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import ContactsUI

class ViewControllerYourEC: UIViewController, UITextFieldDelegate, CNContactPickerDelegate,UITableViewDataSource,UITableViewDelegate  {

    @IBOutlet var tblView: UITableView!
    
        
        //MARK: Outlets and Variables
        
    var result = [[String:String]] () /* In order to add contact into Arr */
        var ContactDictionary = [String:String] ()
        let userDefaults =  UserDefaults.standard
    
        
        override func viewDidLoad() {
            
            //MARK: Textfeild Delegate Methods
            
            super.viewDidLoad()
            AppDelegate.getAppDelegate().checkContactAuthorization()
            
            getEmergencyContacts()
            
        }
        
    
    
    
        //MARK: Table view Datasource Methods
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return result.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "identifier")! as UITableViewCell
            
            var dict = result[indexPath.row]
            
            cell.textLabel?.text = dict["userName"] as String!
            
            cell.detailTextLabel?.text = dict["userContactNo"] as String!
            
            return cell
        }
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
            
            return true
        }
    
        
    
        // MARK: Database Methods
        
        
        func getEmergencyContacts() {
            
            let userId = UserDefaults.standard.value(forKey: "userId") as! String
            let url = "http://188.166.227.51:8080/EmergencyApp/webapi/users/\(userId)/asEmergencyContact"
            AppDelegate.getAppDelegate().showActivityIndicator()

            AppDelegate.getAppDelegate().callWebService(url, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in
               
                
                    DispatchQueue.main.async { () -> Void in
                        AppDelegate.getAppDelegate().hideActivityIndicator()
                        
                        self.parseResponce(result as! [[String : AnyObject]])
                        self.tblView.reloadData()
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
        }
    
        func parseResponce(_ responce : [[String:AnyObject]]) {
            
            for dict in responce {
                var localDict = [String:String] ()
                
                for(key,value) in dict {
                    localDict[key] = "\(value)"
                }
                result.append(localDict)
            }
        }
        
    }
    
    

    
    


