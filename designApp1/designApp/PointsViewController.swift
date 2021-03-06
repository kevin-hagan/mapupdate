//
//  PointsViewController.swift
//  designApp
//
//  Created by Erich Buerkert on 7/2/18.
//  Copyright © 2018 Erich Buerkert. All rights reserved.
//

import UIKit
import SQLite3

class PointsViewController: UIViewController {
    
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    var db: OpaquePointer?
    var userList = [User]()
    var pointsDisplay : Int = 0
    var userID : Int = 0
    
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
        
        readValues()
        
        pointsLabel.text = String(pointsDisplay)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar = tabBarController as! BaseTabBarController
        pointsLabel.text = String(tabBar.points)
    }
    
    func readValues() {
        
        //first empty the list of heroes
        userList.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM userTable"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let userName = String(cString: sqlite3_column_text(stmt, 1))
            let passWord = String(cString: sqlite3_column_text(stmt, 2))
            let points = sqlite3_column_int(stmt, 3)
            
            if id == userID {
                pointsDisplay = Int(points)
            }
            
            print("userName: "+userName)
            print("password: "+passWord)
            print("points: "+String(points))
            
            //adding values to list
            userList.append(User(id: Int(id), userName: String(describing: userName), passWord: String(describing: passWord), points: Int(points)))
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
