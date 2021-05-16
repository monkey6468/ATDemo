//
//  TableViewCell.swift
//  ATDemo(Swift)
//
//  Created by XWH on 2021/5/16.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var yyLabel: YYLabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
//        yyLabel.numberOfLines = 0
//        line.backgroundColor = UIColor.red
    }
}
