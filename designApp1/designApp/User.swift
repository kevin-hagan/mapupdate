//
//  User.swift
//  designApp
//
//  Created by Erich Buerkert on 7/17/18.
//  Copyright © 2018 Erich Buerkert. All rights reserved.
//

import UIKit

class User {
    
    var id: Int
    var userName: String?
    var passWord: String?
    var points: Int
    
    init(id: Int, userName: String?, passWord: String?, points: Int){
        self.id = id
        self.userName = userName
        self.passWord = passWord
        self.points = points
    }
}
