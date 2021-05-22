//
//  ATTextViewBinding.swift
//  ATDemo
//
//  Created by XWH on 2021/5/15.
//

import UIKit
import Foundation

let ATTextBindingAttributeName = "TextViewBingDingFlagName"

class ATTextViewBinding: NSObject {
    var name: String! = ""
    var userId = 0
    var range: NSRange! = NSRange(location: 0, length: 0)

    init(
        name: String?,
        userId: Int
    ) {
        super.init()
            self.name = name
            self.userId = userId
    }
}
