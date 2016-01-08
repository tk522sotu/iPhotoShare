//
//  ViewController.swift
//  PhotoShare
//
//  Created by ie4a on 2015/09/30.
//  Copyright (c) 2015年 ie4a. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController {
    
    
    @IBAction func showEvents(sender: AnyObject) {
        let v = EventsTableViewController(nibName:"EventsTableViewController",bundle: nil)
        self.navigationController?.pushViewController(v, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PhotoShare"
        nowViewController = self
        print(__FUNCTION__)
        
        // 色を変数に用意しておく
        let color = UIColor(red: 183/255, green: 218/255, blue: 152/255, alpha: 1.0)
        
        // 背景の色を変えたい。
        self.navigationController?.navigationBar.barTintColor = color
        
        tryLogin()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tryLogin() {
      
        LOGIN_WITH_EMAIL()
        
    }
    @IBAction func join(sender: UIButton) {
        let a = UIAlertController(title: "JOIN", message: "方法選択", preferredStyle: .ActionSheet)
        a.addAction(UIAlertAction(title: "QR CODE", style: .Default, handler: { (act) -> Void in
            self.performSegueWithIdentifier("JoinQR", sender: nil)
        }))
        a.addAction(UIAlertAction(title: "URL", style: .Default, handler: { (act) -> Void in
//            self.performSegueWithIdentifier("JoinURL", sender: nil)
            let urlAlert = UIAlertController(title: "URL入力", message: nil, preferredStyle: .Alert)
            
            urlAlert.addTextFieldWithConfigurationHandler({ (urlField) -> Void in
                urlField.keyboardType = .URL
                
            })
            urlAlert.addAction(UIAlertAction(title: "接続", style: .Default, handler: { (action) -> Void in
                let url = urlAlert.textFields?[0].text
                print(url)
                self.performSegueWithIdentifier("JoinURLDirect", sender: nil)
                
            }))
            urlAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(urlAlert, animated: true, completion: nil)
            
        }))
        
        a.addAction(UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil))
        
        presentViewController(a, animated: true, completion: nil)
        
    }
    
    @IBAction func NewRoomCreate(sender: AnyObject) {
        
        let v = RoomCreateViewController()
        self.navigationController?.pushViewController(v, animated: true)
        
    }
    
    @IBAction func myResumeButton(sender: AnyObject) {
        
        
    }
}
