//
//  User.swift
//  ATDemo(Swift)
//
//  Created by XWH on 2021/5/16.
//

import Foundation

class User: NSObject {
    var userId = 0 // 用户ID
    var name: String?
    var range: NSRange?
    
    init(
        name: String = "",
        userId: Int
    ) {
        super.init()
            self.name = name
            self.userId = userId
    }
}
