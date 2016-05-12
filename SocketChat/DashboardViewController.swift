//
//  DashboardViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/5/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

var publishersList = [[String: AnyObject]]()

class DashboardViewController: UIViewController {
    
    var publisherUsername: String!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()

    }
    
    @IBOutlet weak var ComponentB: UIView!
    @IBOutlet weak var ComponentA: UIView!

    @IBAction func showComponent(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animateWithDuration(0.5, animations: {
                self.ComponentA.alpha = 0
                self.ComponentB.alpha = 1
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.ComponentA.alpha = 1
                self.ComponentB.alpha = 0
            })
        }
    }
    
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
   
    
    @IBAction func addPublisher(sender: AnyObject) {
        askForPublisher()
    }

    func askForPublisher() {
        let alertController = UIAlertController(title: "Add Publisher", message: "Please enter a username:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let OKAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForPublisher()
            }
            else {
                self.publisherUsername = textfield.text
                
                SocketIOManager.sharedInstance.addSubscription(userInfo[0], publishersUsername: self.publisherUsername, completionHandler: { (publisher) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if publisher != nil {
                            publishersList.append(publisher)

                        }
                    })
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)

    }

}
