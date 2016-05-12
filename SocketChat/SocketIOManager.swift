//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Nithin Reddy Gaddam on 3/22/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    
    //Singleton
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.9:4007")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func sendHeartRate(timeStamp: String, date: String, time:String, hr: String, uuid: String, publisher: String) {
        socket.emit("heartRate", timeStamp, date, time, hr, uuid, publisher)
    }
    
    func login(username: String, password: String, completionHandler: (userData: [String: AnyObject]!) -> Void) {
        
        socket.emit("login", username, password)
        
        socket.on("successLogin") { ( dataArray, ack) -> Void in
            print("Login Success!")
            completionHandler(userData: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }
    
    func register(username: String, password: String, firstName: String, lastName: String, completionHandler: (userData: [String: AnyObject]!) -> Void) {
        
        socket.emit("register", username, password, firstName, lastName)
        
        socket.on("successRegistering") { ( dataArray, ack) -> Void in
            
            completionHandler(userData: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }
    
    func getLatestRecords(user: [String: AnyObject], completionHandler: (latestRecords: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getLatestRecords", user)
        
        socket.on("successLatestRecords") { ( dataArray, ack) -> Void in
            let flag = dataArray[1]
            if (flag as! NSObject == 0){
                completionHandler(latestRecords: dataArray[0] as! [[String: AnyObject]])
            }
            else{
                //garbage values
                completionHandler(latestRecords: [[ "dob": 20, "lastName": 3]])
            }
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }

    
    func getPublishersList(user: [String: AnyObject], completionHandler: (subscriptionData: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getPublishersList", user)
        
        socket.on("successPubList") { ( dataArray, ack) -> Void in
            
            completionHandler(subscriptionData: dataArray[0] as! [[String: AnyObject]] )

        }
    }
    
    func getHeartRates(user: [String: AnyObject], completionHandler: (userHeartRatesData: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getHeartRates", user)
        
        socket.on("successHeartRates") { ( dataArray, ack) -> Void in
            let flag = dataArray[1]
            if (flag as! NSObject == 0){
                completionHandler(userHeartRatesData: dataArray[0] as! [[String: AnyObject]])
            }
            else{
                //garbage values
                completionHandler(userHeartRatesData: [[ "dob": 20, "lastName": 3]])
            }
        }

    }
    
    func getUpdates(user: [String: AnyObject], completionHandler: (messageInfo: [[String: AnyObject]]) -> Void) {
        socket.on("newHeartBeats") { (dataArray, socketAck) -> Void in
            
            let a = dataArray[0]["publisher"] as! String
            let b = user["_id"] as! String
            if(a == b){
               completionHandler(messageInfo: dataArray[0] as! [[String : AnyObject]])
            }
            
        }
    }
    
    
    func addSubscription(userID: String, publishersUsername: String, completionHandler: (subscription: [String: AnyObject]!) -> Void) {
        socket.emit("addSubscription", userID, publishersUsername)
        
        socket.on("successSubscribing") { ( dataArray, ack) -> Void in
            
            print(dataArray[0])
            
            completionHandler(subscription: dataArray[0] as! [String: AnyObject])
        }
    }
    

    

}
