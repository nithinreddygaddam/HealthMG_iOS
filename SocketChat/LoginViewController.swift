//
//  LoginViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 4/24/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import HealthKit

//global array
var userInfo: [String] = []
var user = [String: AnyObject]()

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginAction(sender: AnyObject) {
        // This runs when the button is tapped.
                if(self.username.text != nil && self.password.text != nil){
                    SocketIOManager.sharedInstance.login(self.username.text!, password: self.password.text!, completionHandler: { (userData) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if userData != nil {
            userInfo.append(userData["_id"] as! String)
            userInfo.append(self.username.text!)
            userInfo.append(self.password.text!)
            userInfo.append(userData["firstName"] as! String)
            userInfo.append(userData["lastName"] as! String)
            print(userData)
            user = userData
            
            NSUserDefaults().setObject(userData, forKey: "userData")
            
            SocketIOManager.sharedInstance.getPublishersList( user, completionHandler: {(subscriptionList) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    publishersList = subscriptionList
                    print(publishersList)

                            self.performSegueWithIdentifier("loginSegue", sender: nil)
                    
                })
            })
            
            
        }
        else{
            let alertView = UIAlertController(title: "Login Problem",
                                              message: "Wrong username or password." as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
                        })
                    })
                }
        
    }
    
    
}