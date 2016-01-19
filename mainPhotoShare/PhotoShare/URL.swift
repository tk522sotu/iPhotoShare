//
//  URL.swift
//  PhotoShare
//
//  Created by ZEmac on 2015/12/02.
//  Copyright © 2015年 ie4a. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

func URL(add:String) -> String {
    return "https://www.photoshare.space/\(add)"
}

func SAVEKEY(key:String,value:AnyObject){
    NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
}
func SETKEY(key:String,value:AnyObject?){
    NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
}
func GETKEY(key:String) -> AnyObject? {
    return NSUserDefaults.standardUserDefaults().valueForKeyPath(key)
}

func LOGIN(var LOGIN_NAME: String! = nil,var token: String! = nil, complete:((result: JSON)->Void)? = nil){
    print("LOGINing")
    REGISTER_LOGIN_NAME() {
        newuser in
        GET_TOKEN(true){
            newtoken in
            //did get _token
            LOGIN_NAME = LOGIN_NAME ?? GETKEY("LOGIN_NAME") as? String
            token = token ?? GETKEY("_token") as? String
            
            let url = URL("auth/login-name?login_name=\(LOGIN_NAME)&_token=\(token)&mobile=1")
            
            mgr.request(.POST, url)
                .responseJSON { (response) -> Void in//ログイン成功
                    print(response.debugDescription)
                    if let json = response.result.value {
                        if complete != nil{
                            complete!(result: JSON(json))
                        }
                    }else{
                        let alert = UIAlertController(title: "ログインできません", message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "了解", style: .Default, handler: nil))
                        nowViewController!.presentViewController(alert, animated: false, completion: nil)
                    }
            }
        }
    }
}

func LOGIN_WITH_EMAIL(email:String? = nil , password : String? = nil, done: ((user: AnyObject?)-> Void)? = nil){
    
    print( Defaults.login_data)
    
    guard var login_data = Defaults.login_data else {
        
        showLoginViewController()
        
        return
    }
    //    var login_data = [String: AnyObject]()
    
    if email != nil {
        login_data["email"] = email
    }
    if password != nil {
        login_data["password"] = password
    }
    
    build_data(login_data) { (all_data) -> Void in
        print("all_data",all_data)
        mgr.request(.POST, URL("auth/login"), parameters : all_data)
            
            .responseString(completionHandler: { (res) -> Void in
                
                debugPrint(res)
                
            })
            .responseJSON { (res) -> Void in
                
                //                debugPrint(res)
                
                if let err = res.result.error {
                    
                    debugPrint(err)
                    
                    showLoginViewController()
                    
                    return
                }
                
                let user = res.result.value
                
                //ログイン成功のデータをロカルに保存
                Defaults.login_data = all_data
                
                let user_json = JSON(res.result.value ?? [])
                if let user_json = user_json.dictionary {
                    for (k,val) in user_json {
                        Defaults.setValue(val.stringValue, forKeyPath: "user_\(k)")
                    }
                    print("user_id",Defaults.value("user_id"))
                }
                done?(user: user)
        }
    }
    
    
}

func build_data(var data : [String: AnyObject], done: ((all_data: [String: AnyObject])->Void)){
    
    GET_TOKEN(true) { (token) -> Void in
        data["_token"] = token
        data["mobile"] = "1"
        data["remember"] = "1"
        done(all_data: data)
    }
    
}

func showLoginViewController(){
    
    print(__FUNCTION__)
    print(    nowViewController?.navigationController)
    let v = LoginViewController()
    
    nowViewController?.presentViewController(v, animated: true, completion: nil)
}

func REGISTER_LOGIN_NAME(var token:String! = nil, complete: ((user: AnyObject?)->Void)? = nil) {
    
    print(__FUNCTION__)
    
    func new_register(){
        GET_TOKEN(true) {
            newtoken in
            token = token ?? GETKEY("_token") as! String
            
            /*
            new user register
            */
            
            mgr.request(.POST, URL("auth/register-login-name"), parameters: ["login_name" : NSUUID().UUIDString, "_token": token, ])
                .responseJSON { (res) -> Void in
                    
                    debugPrint(res)
                    if let user = res.result.value {
                        let json = JSON(user)
                        SETKEY("LOGIN_NAME", value: json["newUser"]["login_name"].string)
                        if complete != nil {
                            complete!(user: user)
                        }
                    }
                }.responseString{
                    string in
                    print(string)
            }
        }
    }
    
    if GETKEY("LOGIN_NAME") == nil {
        new_register()
    }else{
        if complete != nil {
            complete!(user:nil)
        }
    }
    
    
}

func GET_TOKEN(refresh:Bool = false, complete: ((token:String) -> Void)? = nil) {
    func refreshTOKEN() {
        mgr.request(.GET,URL("token"))
            .responseString { (res) -> Void in
                
                if let token = res.result.value {
                    
                    SAVEKEY("_token", value: token)
                    
                    Defaults.token = token
                    
                    
                    complete?(token: token )
                    
                    
                }
        }
    }
    if refresh {
        refreshTOKEN()
    }else{
        if let token = GETKEY("_token") {
            if complete != nil{
                complete!(token: token as! String)
            }
        }else{
            refreshTOKEN()
        }
    }
}

let BASE_URL = "https://www.photoshare.space"
var GLO_PARAMS : [String:String] = ["mobile":"1"]

enum URL_TYPE : String {
    case LOGIN = "/auth/login"
    case TOKEN = "/token"
    case EVENTS = "/events"
    case PHOTOS = "/events/photos"
    case EVENT_CREATE = "/events/create"
}
func baseUrl(append: URL_TYPE? = nil) -> String {
    var url = BASE_URL
    if append != nil {
        url += append!.rawValue
    }
    return url
}


func goToCamera(){
    
    print(__FUNCTION__)
    
    //    let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CamController") as! CamController
    
    let v = MaterialPickerViewController()
    
    sliceVC.presentViewController(v, animated: true, completion: nil)
}

func joinLink(var event : JSON,done:((JSON )->Void)? = nil) {
    let url  = URL("events/join/?event_id=" + event["id"].stringValue)
    joinLink(url) {
        done_json in
        done?(done_json)
    }
}

func joinLink(var url:String, done:((JSON )->Void)? = nil) {
    
    if NSUUID(UUIDString: url) != nil {//uuid check
        
        url = URL("events/join/" + url)
        
    }
    
    url = url.stringByReplacingOccurrencesOfString("https://photoshare.space", withString: "https://www.photoshare.space")
    url += "?mobile=1"
    
    print(__FUNCTION__,url)
    
    mgr.request(.GET, url)
        
        .responseJSON { (res) -> Void in
            
            let j = JSON(res.result.value ?? [])
            
            if j["joined"].boolValue {//joined ok
                
                Defaults.last_event_id = j["event","id"].stringValue
                
                if let event = j["event"].dictionary {
                    
                    for  (k , obj) in event {
                        Defaults.setValue(obj.stringValue, forKeyPath: k)
                    }
                }
                
                
                done?(j)
                
            }else{//joined NG
                sliceVC.alert(j["note"].stringValue, message: nil)
            }
            
        }
        .responseString { (res) -> Void in
            print(res)
            
    }
}

func docDirSave(fileName:String = "last_event", json: JSON) -> Bool {
    
    let docDir  = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) ).first!
    
    let path = docDir.stringByAppendingString("/" + fileName)
    
    let d = json.description.dataUsingEncoding(NSUTF8StringEncoding)
    
    if let data = d {
        return data.writeToFile(path, atomically: true)
    }
    
    return false
}
func docDir(fileName: String) -> String {
    let docDir  = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) ).first!
    let path = docDir.stringByAppendingString("/" + fileName)
    return path
}
//func LOGIN(email:String? = nil, password: String? = nil, token :String? = nil,done: (()->Void)?){
//
//    GLO_PARAMS["_token"] = token ?? Defaults.token
//    GLO_PARAMS["email"] = email ?? Defaults.email
//    GLO_PARAMS["password"] = password ?? Defaults.password
//
//    func login(){
//        print(GLO_PARAMS)
//        request(.POST, URL(.LOGIN),parameters: GLO_PARAMS)
//            .responseJSON(completionHandler: { (res) -> Void in
//
//                //failed?
//                if let err = res.result.error {
//                    print(err)
//                    navController?.alert("can not login", message: err.description)
//                    return
//                }
//                //success?
//                Defaults.user = res.result.value
//                done?()
//            })
//            .responseString { (res) -> Void in
//                debugPrint(res)
//        }
//    }
//
//    if GLO_PARAMS["_token"] == nil {
//
//        request(.GET, URL(.TOKEN)).responseString(completionHandler: { (res) -> Void in//token
//            Defaults.token = res.result.value
//            GLO_PARAMS["_token"] = Defaults.token
//            login()
//        })
//
//    }else{
//        login()
//    }
//
//}

//func EVENTS(done:((events: JSON)->Void)?){
//
//    let req = request(.GET, URL(.EVENTS))
//
//    req.responseJSON(completionHandler: { (res) -> Void in
//
//        if let err = res.result.error {
//            debugPrint(err)
//            let log = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//            navController?.pushViewController(log,animated: true)
//
//        }
//        let j = JSON(res.result.value ?? [])
//
//        done?(events: j)
//
//    })
//
//    debugPrint(req)
//}
