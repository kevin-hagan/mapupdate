//
//  CheckinViewController.swift
//  designApp
//
//  Created by Erich Buerkert on 6/21/18.
//  Copyright © 2018 Erich Buerkert. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite3

class CheckinViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    //Connectives -------------------
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var isGameLabel: UILabel!
    
    //Date arrays -------------------
    
    let baseballArr = ["03/14/2019 ~ 16","03/28/2019 ~ 15","04/2/2019 ~ 15","04/6/2019 ~ 12","04/12/2019 ~ 15","04/16/2019 ~ 15","04/20/2019 ~ 12","04/26/2019 ~ 15"]
    
    let softballArr = ["03/14/2019 ~ 15","03/16/2019 ~ 13","03/19/2019 ~ 15","03/30/2019 ~ 13","04/2/2019 ~ 15","04/9/2019 ~ 15","04/20/2019 ~ 13","04/25/2019 ~ 15"]
    
    let womensLaxArr = ["03/13/2019 ~ 16","03/15/2019 ~ 18","03/21/2019 ~ 16","03/23/2019 ~ 13","03/30/2019 ~ 13","04/6/2019 ~ 18","04/20/2019 ~ 13","04/24/2019 ~ 16"]
    
    let mensLaxArr = ["03/2/2019 ~ 13","03/13/2019 ~ 19","03/16/2019 ~ 13","03/31/2019 ~ 14","04/5/2019 ~ 7:00","04/20/2019 ~ 16","04/24/2019 ~ 19", "02/27/2019 ~ 19"]
    
    // location arrays ----------------
    // order is left, right, top, bottom
    
    let baseballLocArr = [-75.550644, -75.547910, 40.581278, 40.578608];
    
    let softballLocArr = [-75.548568, -75.546874, 40.582034, 40.580788];
    
    let laxLocArr = [-75.512467, -75.510091, 40.599282, 40.598166];
    
    // bool for at the games ------------
    
    var atBaseball = false;
    var atSoftball = false;
    var atLax = false;
    
    //Attributes --------------------
    var db: OpaquePointer?
    
    var thereIsGame = false
    var eventFound = false
    var locationFound = false
    var inGeoRegion = false
    
    var userID : Int = 0     //id from userTable
    var pickTitle : Int = 0
    
    let locationManager : CLLocationManager = CLLocationManager()

    //Picker View -----------------------
    
    let sports = ["Baseball", "Softball", "Men's Lacrosse", "Women's Lacrosse"]
    let sportsNum = [1,2,3,4]
    //make an array for the different amounts of time that will be added to current time
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickTitle = sportsNum[row]
        return sports[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sports.count
    }
    
    //Timer -----------------------
    
    var seconds = 10
    var timer = Timer()
    var isTimerRunning = false  //only one timer is running
    
    //Date ------------------------
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func getTime() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        //let minutes = calendar.component(.minute, from: date)
        //let result = String(hour)+":"+String(minutes)
        return hour
    }
    
    //CheckinButton
    
    @IBAction func checkinButton(_ sender: UIButton) {
        
        isGameLabel.text = ""
        
        if isTimerRunning == false {
        
            checkGame()
            
            if(thereIsGame == true) {
                
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CheckinViewController.counter), userInfo: nil, repeats: true)
                        isTimerRunning = true
            }
            
        }
    }
    
    //Timer Stuff
    
    @objc func counter() {
        seconds -= 1
        timerLabel.text = timeString(time: TimeInterval(seconds))
        
        if (seconds == 0) {
            timer.invalidate()
            isTimerRunning = false
            seconds = 10
            timerLabel.text = timeString(time: TimeInterval(seconds))
            
            var stmt: OpaquePointer?
            
            let queryString = "UPDATE userTable SET points = (points + 1) WHERE id = ?";
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int(stmt, 1, Int32(userID)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting user: \(errmsg)")
                return
            }
            
            let tabBar = tabBarController as! BaseTabBarController
            tabBar.points = tabBar.points + 1
            
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    //-----------------
    
    // Cancel Button
    
    @IBAction func cancelButton(_ sender: UIButton) {
        timer.invalidate()
        isTimerRunning = false
        seconds = 10
        timerLabel.text = timeString(time: TimeInterval(seconds))
        eventFound = false
        locationFound = false
        thereIsGame = false
        inGeoRegion = false
    }
    
    // ===========================
    
    func checkGame() {
        
        let currentTime = getTime()
        let currentDate = getDate()
        
        let timeDateString = String(currentDate)+" ~ "+String(currentTime)
        let timeDateString2 = String(currentDate)+" ~ "+String(currentTime-1)
        
        print(timeDateString)
        print(timeDateString2)
        
        if atBaseball {
            if baseballArr.contains(timeDateString){
                thereIsGame = true;
            } else if baseballArr.contains(timeDateString2){
                thereIsGame = true;
            }
        }
        
        if atSoftball {
            if softballArr.contains(timeDateString){
                thereIsGame = true;
            } else if softballArr.contains(timeDateString2){
                thereIsGame = true;
            }
        }
        
        if atLax {
            if womensLaxArr.contains(timeDateString){
                thereIsGame = true;
            } else if womensLaxArr.contains(timeDateString2){
                thereIsGame = true;
            } else if mensLaxArr.contains(timeDateString){
                thereIsGame = true;
            } else if mensLaxArr.contains(timeDateString2){
                thereIsGame = true;
            }
        }
        
 
        if (thereIsGame == false) {
            isGameLabel.text = "There is no game at this time."
        }
        
        if (thereIsGame == true) {
            isGameLabel.text = "Enjoy the game"
        }
    }
    

   
    // ===========================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = tabBarController as! BaseTabBarController
        userID = tabBar.userID
        
        //database stuff
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Users1.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isGameLabel.text = ""
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
           
            if currentLocation.coordinate.longitude > baseballLocArr[0] && currentLocation.coordinate.longitude < baseballLocArr[1] && currentLocation.coordinate.latitude < baseballLocArr[2] && currentLocation.coordinate.latitude > baseballLocArr[3] {
                atBaseball = true;
            } else if currentLocation.coordinate.longitude > softballLocArr[0] && currentLocation.coordinate.longitude < softballLocArr[1] && currentLocation.coordinate.latitude < softballLocArr[2] && currentLocation.coordinate.latitude > softballLocArr[3] {
                atSoftball = true;
            } else if currentLocation.coordinate.longitude > laxLocArr[0] && currentLocation.coordinate.longitude < laxLocArr[1] && currentLocation.coordinate.latitude < laxLocArr[2] && currentLocation.coordinate.latitude > laxLocArr[3] {
                atLax = true;
                print("at lacrosse");
            } else {
                atBaseball = false;
                atSoftball = false;
                atLax = false;
            }
            
            
        }
    }
    
}

