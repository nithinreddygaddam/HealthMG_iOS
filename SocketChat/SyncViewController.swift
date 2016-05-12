//
//  SyncViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/10/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit



var writeLock = 0

class SyncViewController: UIViewController {

    let healthManager:HealthManager = HealthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        
    }

    
    @IBAction func action(sender: AnyObject) {
        loadData()
    }
    
    func loadData(){
        //syncronizing heart rates
        SocketIOManager.sharedInstance.getLatestRecords( user, completionHandler: {(latestRecords) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print(latestRecords)
                
                ///check if authorization is working
                if(latestRecords[0]["_id"] == nil && writeLock == 0)
                {
                    writeLock = 1
                    self.healthManager.updateHearRate(user, startDate2: " ")
                    writeLock = 0
                    self.performSegueWithIdentifier("syncSegue", sender: nil)
                    
                }
                else if(writeLock == 0){
                    writeLock = 1
                    print(latestRecords[0]["timeStamp"] as! String)
                    self.healthManager.updateHearRate(user, startDate2: latestRecords[0]["timeStamp"] as! String)
                    writeLock = 0
                    
                    SocketIOManager.sharedInstance.getHeartRates(user, completionHandler: {(userHeartRatesData) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if(userHeartRatesData[0]["_id"] == nil)
                            {
                            }
                            else {
                                userHeartRates = userHeartRatesData
                                print("Heart rates Done!")
//                                print(userHeartRates)
                                self.performSegueWithIdentifier("syncSegue", sender: nil)
                            }
                            
                        })
                    })

                    
                }
                
//                    })
//                })
            })
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
