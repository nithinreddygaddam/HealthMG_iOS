//
//  CurrentDashboardViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/11/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Charts

var userHeartRates = [[String: AnyObject]]()

class CurrentDashboardViewController: UIViewController {


    var yaxis = [String]()
    var rates =  [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        let name = user["firstName"] as? String
        let lastName = user["lastName"] as? String
        lblUsername.text  = name! + " " + lastName!
        barChartView.noDataText = "No data to load"
        
        
        if(!userHeartRates.isEmpty){
            for obj in userHeartRates {
                let stamp2 = obj["time"] as? String
                yaxis.append(stamp2!)
                let hr = obj["heartRate"] as? String
                let hr2 = Double(hr!)
                rates.append(hr2!)
            }
            setChart(yaxis, values: rates)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBAction func dataFrequency(sender: AnyObject) {
    }
    
    @IBOutlet weak var lblUsername: UILabel!

    func setChart(dataPoints: [String], values: [Double]) {
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: yaxis, dataSet: chartDataSet)
        barChartView.data = chartData
        
        
    }

    //Method used to recieve message
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!userHeartRates.isEmpty){
            for obj in userHeartRates {
                let stamp2 = obj["time"] as? String
                yaxis.append(stamp2!)
                let hr = obj["heartRate"] as? String
                let hr2 = Double(hr!)
                rates.append(hr2!)
            }

            setChart(yaxis, values: rates)
        }

        
        SocketIOManager.sharedInstance.getUpdates(user, completionHandler: { (heartBeat) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.chatMessages.append(messageInfo)
//                self.tblChat.reloadData()
                
//                if(!heartBeat.isEmpty){
//                    //            var counter = 0
//                    for obj in heartBeat {
//                        //                let stamp = obj["date"] as? String
//                        let stamp2 = obj["time"] as? String
//                        //                stamp2 = stamp2! + " " + stamp!
//                        yaxis.append(stamp2!)
//                        let hr = obj["heartRate"] as? String
//                        let hr2 = Double(hr!)
//                        rates.append(hr2!)
//                        //                counter += 1
//                    }
//                    //            print(yaxis)
//                    //            print(rates)
//                    setChart(yaxis, values: rates)
//                }

            })
        })
        
    }

}
