//
//  ListViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/9/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

var publisherHeartRates = [[String: AnyObject]]()
var tableIndex = 0

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publishersList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
       let firstName = publishersList[indexPath.row]["firstName"] as? String
        let lastName = publishersList[indexPath.row]["lastName"] as? String
        
        let Name = firstName! + " " + lastName!
         cell.textLabel?.text = Name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SocketIOManager.sharedInstance.getHeartRates(publishersList[indexPath.row], completionHandler: {(publisherHeartRatesData) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(publisherHeartRatesData[0]["_id"] == nil)
                {
                }
                else {
                    tableIndex = indexPath.row
                    publisherHeartRates = publisherHeartRatesData
                    self.performSegueWithIdentifier("publisherSegue", sender: nil)
                }
                
            })
        })

    }
    

}
