//
//  HealthManager.swift
//  HKTutorial
//
//  Created by Nithin Reddy Gaddam on 4/08/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager{
    
    var loggedinUser = [String: AnyObject]()
  let healthKitStore:HKHealthStore = HKHealthStore()

  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
  {
    // 1. Set the types you want to read from HK Store
    let healthKitTypesToRead = Set(arrayLiteral:
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
      HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
      HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
      HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
      HKObjectType.workoutType()
      )

    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: "com.nithinreddygaddam.SocketChat", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil )
      {
        completion(success:false, error:error)
      }
      return;
    }

    // 4.  Request HealthKit authorization
    healthKitStore.requestAuthorizationToShareTypes( nil , readTypes: healthKitTypesToRead) { (success, error) -> Void in

      if( completion != nil )
      {
        completion(success:success,error:error)
      }
    }
  }
  
  func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
  {
    var error:NSError?
    var age:Int?

    // 1. Request birthday and calculate age
    do {
      let birthDay = try healthKitStore.dateOfBirth()
      age = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: NSDate(), options: []).year
    } catch let error1 as NSError {
      error = error1
    }
    if error != nil {
      print("Error reading Birthday: \(error)")
    }

    // 2. Read biological sex
    var biologicalSex:HKBiologicalSexObject?
    do {
      biologicalSex = try healthKitStore.biologicalSex()
    } catch let error1 as NSError {
      error = error1
      biologicalSex = nil
    };
    if error != nil {
      print("Error reading Biological Sex: \(error)")
    }
    // 3. Read blood type
    var bloodType:HKBloodTypeObject?
    do {
      bloodType = try healthKitStore.bloodType()
    } catch let error1 as NSError {
      error = error1
      bloodType = nil
    };
    if error != nil {
      print("Error reading Blood Type: \(error)")
    }

    // 4. Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  
    

    var hkAnchor =  HKQueryAnchor(fromValue: UInt(HKAnchoredObjectQueryNoAnchor));
    let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    lazy var query: HKObserverQuery = {[weak self] in
    let strongSelf = self!
    return HKObserverQuery(sampleType: strongSelf.heartRateType,
        predicate : nil, //all samples delivered
        updateHandler: strongSelf.heartRateChangedHandler)
    }()
    
    //query Health data


    func startObservingHeartRateChanges(){
    healthKitStore.executeQuery(query)
    healthKitStore.enableBackgroundDeliveryForType(heartRateType,
                                                    frequency: .Immediate,
                                                    withCompletion: {(succeeded: Bool, error: NSError?) in
                                                        
                                                        if succeeded{
                                                            print("Enabled background delivery of heart rate changes")
                                                        } else {
                                                            if let theError = error{
                                                                print("Failed to enable background delivery of heart rate changes. ")
                                                                print("Error = \(theError)")
                                                            }
                                                        }
                                                        
    })
    }
    
    let AnchorKey = "HKClientAnchorKey"
    func getAnchor() -> HKQueryAnchor? {
        let encoded = NSUserDefaults.standardUserDefaults().dataForKey(AnchorKey)
        if(encoded == nil){
            return nil
        }
        let anchor = NSKeyedUnarchiver.unarchiveObjectWithData(encoded!) as? HKQueryAnchor
        return anchor
    }
    
    func saveAnchor(anchor : HKQueryAnchor) {
        let encoded = NSKeyedArchiver.archivedDataWithRootObject(anchor)
        NSUserDefaults.standardUserDefaults().setValue(encoded, forKey: AnchorKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

var queryStartDate =  NSDate()

///** this should get called in the background */
func heartRateChangedHandler(query: HKObserverQuery!,
                          completionHandler: HKObserverQueryCompletionHandler!,
                          error: NSError?){
    
    NSLog(" Got an update Here ")
    
        let timeFormatter = NSDateFormatter()
    timeFormatter.dateFormat = "hh:mm:ss"
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    
    
        let onAnchorQueryResults : ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, NSError?) -> Void)! = {
            (query:HKAnchoredObjectQuery, addedObjects:[HKSample]?, deletedObjects:[HKDeletedObject]?, newAnchor:HKQueryAnchor?, nsError:NSError?) -> Void in

            if (addedObjects?.count > 0 && !self.loggedinUser.isEmpty){
             
                
                for obj in addedObjects! {
                    let quant = obj as? HKQuantitySample
                    if(quant?.UUID.UUIDString != nil){
                        let time = timeFormatter.stringFromDate(quant!.startDate)
                        let date = dateFormatter.stringFromDate(quant!.startDate)
                        let val = String( (quant?.quantity.doubleValueForUnit(HKUnit(fromString: "count/min")))! )
                        let uuid : String = (quant?.UUID.UUIDString)!
                        print("\(quant!.startDate),\(uuid),  -- \(val)")
                        let timeStamp = String(quant!.startDate)
                        
                        SocketIOManager.sharedInstance.sendHeartRate(timeStamp, date: date, time: time, hr: val, uuid: uuid, publisher: self.loggedinUser["_id"] as! String)
                        
                    }
                }

            }
            
        }
    
    let queryEndDate = NSDate()
    let sampleType: HKSampleType = heartRateType as HKSampleType
    print("Before Start: ")
    print(self.queryStartDate)
    let predicate: NSPredicate = HKAnchoredObjectQuery.predicateForSamplesWithStartDate(self.queryStartDate, endDate: queryEndDate, options: HKQueryOptions.None)
    
    print("After: ")
    print(self.queryStartDate)
    
    let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: hkAnchor, limit: 0, resultsHandler: onAnchorQueryResults)
    anchoredQuery.updateHandler = onAnchorQueryResults
    healthKitStore.executeQuery(anchoredQuery)
    self.queryStartDate = queryEndDate
    
    //this function will get called each time a new heart Rate sample is added to healthKit.
 
 // query for the changed values..
 //using the standard query functions in HealthKit.. 
 
 completionHandler()
 }

    
    func updateHearRate(user: [String: AnyObject], startDate2: String){
        let tempUser = (NSUserDefaults().objectForKey("userData") as? [String: AnyObject])
        self.loggedinUser = tempUser!
                //Date Conversion
                let dateFormater = NSDateFormatter()
                dateFormater.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                if (startDate2 == " ")
                {
                    let past = NSDate.distantPast() as NSDate
                    queryStartDate = past
        }
                else{
                    queryStartDate = dateFormater.dateFromString(startDate2)!
                    
                    print("queryStartDate: ")
                    
                    print(queryStartDate)
        }
        
                if (HKHealthStore.isHealthDataAvailable()){
                    let queryEndDate = NSDate()
                    let predicate: NSPredicate = HKSampleQuery.predicateForSamplesWithStartDate(queryStartDate, endDate: queryEndDate, options: HKQueryOptions.None)
                    queryStartDate = queryEndDate
        
                    self.healthKitStore.requestAuthorizationToShareTypes(nil, readTypes:[heartRateType], completion:{(success, error) in
                        let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                        let timeFormatter = NSDateFormatter()
                        timeFormatter.dateFormat = "hh:mm:ss"
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MM/dd"
        
                        let query = HKSampleQuery(sampleType:self.heartRateType, predicate:predicate, limit:0, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                            guard let results = results else { return }
                            for quantitySample in results {
                                let quant = (quantitySample as? HKQuantitySample)
                                
                                if(quant?.UUID.UUIDString != nil){
                                    let time = timeFormatter.stringFromDate(quant!.startDate)
                                    let date = dateFormatter.stringFromDate(quant!.startDate)
                                    let val = String( (quant?.quantity.doubleValueForUnit(HKUnit(fromString: "count/min")))! )
                                    let uuid : String = (quant?.UUID.UUIDString)!
                                    print("\(quant!.startDate),\(uuid),    : \(val)")
                                    let timeStamp = String(quant!.startDate)
//                                    userHeartRates!.setValue(val, forKey: timeStamp)
                                    SocketIOManager.sharedInstance.sendHeartRate(timeStamp, date: date, time: time, hr: val, uuid: uuid, publisher: self.loggedinUser["_id"] as! String)
                                    
                                }

        
                            }
                            
                        })
                        self.healthKitStore.executeQuery(query)
                    })
                }
    }
    
    
//    func getPublishersList(user: [String: AnyObject], completionHandler: (subscriptionData: [[String: AnyObject]]!) -> Void) {
//        
//        socket.emit("getPublishersList", user)
//        
//        socket.on("successPubList") { ( dataArray, ack) -> Void in
//            
//            completionHandler(subscriptionData: dataArray[0] as! [[String: AnyObject]] )
//            
//        }
//    }
    
//    func getHeartRates(completionHandler: (userHeartRates: [[String: AnyObject]]!)  -> Void) {
//        
//        var userHeartRates = [[String: AnyObject]]()
//        
//        let past = NSDate.distantPast() as NSDate
//        if (HKHealthStore.isHealthDataAvailable()){
//            let queryEndDate = NSDate()
//            let predicate: NSPredicate = HKSampleQuery.predicateForSamplesWithStartDate(past, endDate: queryEndDate, options: HKQueryOptions.None)
//            
//            self.healthKitStore.requestAuthorizationToShareTypes(nil, readTypes:[heartRateType], completion:{(success, error) in
//                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
//                let timeFormatter = NSDateFormatter()
//                timeFormatter.dateFormat = "hh:mm:ss"
//                
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.dateFormat = "MM/dd/YYYY"
//                
//                let query = HKSampleQuery(sampleType:self.heartRateType, predicate:predicate, limit:0, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
//                    guard let results = results else { return }
//                    for quantitySample in results {
//                        let quant = (quantitySample as? HKQuantitySample)
//                        
//                        if(quant?.UUID.UUIDString != nil){
//                            let time = timeFormatter.stringFromDate(quant!.startDate)
//                            let date = dateFormatter.stringFromDate(quant!.startDate)
//                            let val = String( (quant?.quantity.doubleValueForUnit(HKUnit(fromString: "count/min")))! )
//                            let uuid : String = (quant?.UUID.UUIDString)!
//                            print("\(quant!.startDate),\(uuid),    $$ \(val)")
//                            let timeStamp = String(quant!.startDate)
//
//                            userHeartRates.append(["time": time, "date": date, "timeStamp": timeStamp, "hr": val])
//                            
//                        }
//                        
//                        
//                    }
//                    
//                })
//                self.healthKitStore.executeQuery(query)
//                completionHandler(userHeartRates: userHeartRates )
//            })
//        }
//       
//    }

    


    
    
}