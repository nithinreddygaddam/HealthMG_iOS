//
//  PublisherViewController.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 5/11/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Charts

class PublisherViewController: UIViewController {

    var yaxis2 = [String]()
    var rates2 =  [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let name = publishersList[tableIndex]["firstName"] as? String
        let lastName = publishersList[tableIndex]["lastName"] as? String
        publisher.text  = name! + " " + lastName!
        barChartView.noDataText = "No data to load"
        
        if(!publisherHeartRates.isEmpty){
            for obj in publisherHeartRates {
                let stamp2 = obj["time"] as? String
                yaxis2.append(stamp2!)
                let hr = obj["heartRate"] as? String
                let hr2 = Double(hr!)
                rates2.append(hr2!)
            }
            setChart(yaxis2, values: rates2)
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var publisher: UILabel!
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: yaxis2, dataSet: chartDataSet)
        barChartView.data = chartData
        
        
    }
    
    //Method used to recieve message
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getUpdates(publishersList[tableIndex], completionHandler: { (heartBeat) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //                self.chatMessages.append(messageInfo)
                //                self.tblChat.reloadData()
                
                //                if(!heartBeat.isEmpty){
                //                    //            var counter = 0
                //                    for obj in heartBeat {
                //                        //                let stamp = obj["date"] as? String
                //                        let stamp2 = obj["time"] as? String
                //                        //                stamp2 = stamp2! + " " + stamp!
                //                        yaxis2.append(stamp2!)
                //                        let hr = obj["heartRate"] as? String
                //                        let hr2 = Double(hr!)
                //                        rates2.append(hr2!)
                //                        //                counter += 1
                //                    }
                //                    //            print(yaxis2)
                //                    //            print(rates2)
                //                    setChart(yaxis2, values: rates2)
                //                }
                
            })
        })
        
    }


}
