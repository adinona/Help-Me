//
//  MenuDrawer.swift
//  EmergencyApplication
//
//  Created by Aditya Bhandari on 4/15/16.
//  Copyright © 2016 Aditya Bhandari. All rights reserved.
//

import UIKit

protocol MenuDrawerDelegate {
    func selectIndexInMenu(_ index : Int32)
}

class MenuDrawer: UIView ,UITableViewDataSource,UITableViewDelegate{
    
    var delegate : MenuDrawerDelegate?
    
    var btnMenu : UIButton?
    
    @IBOutlet var tblMenu: UITableView!

    var arrayMenuOptions = [Dictionary<String,String>]()
    
    override func awakeFromNib() {
        
        self.addSlideMenuButton()
        //arrayMenuOptions.append(["title":"Home", "icon":"App_Icon_60pts@3x.png"])
        arrayMenuOptions.append(["title":"Emergency Contacts", "icon":"ec"])
        arrayMenuOptions.append(["title":"As Emergency Contact","icon":"my_contacts_backup_logo"])
        arrayMenuOptions.append(["title":"Logout", "icon":"log out"])
        tblMenu.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrayMenuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.selectIndexInMenu(Int32(indexPath.row))
        
    }
    
    //MARK: Adding Menu Button in navigation bar
    func addSlideMenuButton() -> UIBarButtonItem{
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.tag = 1010
        btnShowMenu.addTarget(self, action: #selector(MenuDrawer.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        
        return customBarItem
    }
    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        
        self.isHidden = false
        if (sender.tag == 10)
        {
            sender.tag = 0;
            
            btnMenu = nil
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = self.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                self.frame = frameMenu

                }, completion: { (finished) -> Void in
            })
            return
        }
        sender.isEnabled = false
        sender.tag = 10
        btnMenu = sender
        self.frame.origin.x = (-1) * UIScreen.main.bounds.size.width
        self.frame.size.height = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.frame.origin.x = 0
             sender.isEnabled = true
            },completion:nil)
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }    
}
