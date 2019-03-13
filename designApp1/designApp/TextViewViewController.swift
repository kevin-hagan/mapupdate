//
//  TextViewViewController.swift
//  designApp
//
//  Created by Erich Buerkert on 7/24/18.
//  Copyright © 2018 Erich Buerkert. All rights reserved.
//

import UIKit

class TextViewViewController: UIViewController {
    
    @IBOutlet weak var schedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        schedLabel.text = sportSched[myIndex]
        // Do any additional setup after loading the view.
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
