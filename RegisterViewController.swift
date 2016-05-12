//
//  RegisterViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/3/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    
    @IBAction func registerAction(sender: AnyObject) {
        if(self.username.text != nil && self.password.text != nil && self.firstName.text != nil && self.lastName.text != nil){
            SocketIOManager.sharedInstance.register(self.username.text!, password: self.password.text!, firstName: self.firstName.text!, lastName: self.lastName.text!, completionHandler: { (userData) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if userData != nil {
                        print(userData)
                        userInfo.append(userData["_id"] as! String)
                        userInfo.append(self.username.text!)
                        userInfo.append(self.password.text!)
                        userInfo.append(self.firstName.text!)
                        userInfo.append(self.lastName.text!)
                      
                        
                        self.performSegueWithIdentifier("registerSegue", sender: nil)
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
