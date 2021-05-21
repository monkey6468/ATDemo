//
//  TextViewBinding.swift
//  ATDemo
//
//  Created by XWH on 2021/5/15.
//

import UIKit
import Foundation

let TextBindingAttributeName = "TextViewBingDingFlagName"
let kATRegular = "@[\\u4e00-\\u9fa5\\w\\-\\_]+ "
let k_default_attributedTextColor = UIColor.black
let k_hightColor = UIColor.red
let k_defaultFont =  UIFont.systemFont(ofSize: 18)

class TextViewBinding: NSObject {
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
