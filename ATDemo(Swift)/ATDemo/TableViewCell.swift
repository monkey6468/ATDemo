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
    
    var _model: DataModel!
    public var model: DataModel! {
        set {
            _model = newValue

            let muAttriSting: NSMutableAttributedString = NSMutableAttributedString(string: newValue.text)
            muAttriSting.yy_font = UIFont.systemFont(ofSize: 25)
            muAttriSting.yy_color = UIColor.purple
            
            let arr = model.userList!
            for bindingModel in arr {
                muAttriSting.yy_setTextHighlight(NSRange(location: bindingModel.range.location, length: bindingModel.range.length), color: .red, backgroundColor: .darkGray, userInfo: ["id": bindingModel.userId]) { containerView, text, range, rect in
                    
                    let yyLabel = containerView as! YYLabel
                    let highlight = yyLabel.value(forKey: "_highlight") as! YYTextHighlight
                    let dictInfo: NSDictionary? = highlight.userInfo as NSDictionary?
                    if dictInfo == nil {
                        return
                    }
                    
                    let toUserId = dictInfo?["id"] as! Int
                    print("点击了: \(toUserId)");

                } longPressAction: { _,_,_,_ in }

            }
            yyLabel.attributedText = muAttriSting
            
        } get {
            return _model
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        yyLabel.numberOfLines = 0
        self.setupGesture()
    }
    
    func setupGesture() {
        let contentTap = UITapGestureRecognizer(target: self, action: #selector(onTapReply(_:)))
        contentTap.delegate = self
        yyLabel.addGestureRecognizer(contentTap)
    }
    
    public class func rowHeightWithModel(model: DataModel) -> CGFloat {
        let height = (model.text.heightWithFont(font: UIFont.systemFont(ofSize: 25), fixedWidth: UIScreen.main.bounds.size.width)) as CGFloat
        return height+5
    }
    
    @objc func onTapReply(_ sender: UITapGestureRecognizer) {
        print("点击了cell22")
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if ((touch.view?.isKind(of: YYLabel.self)) != nil) {
            let label = touch.view as! YYLabel
            var highlightRange: NSRange = NSRange(location: 0, length: 0)
            let highlight: YYTextHighlight?
                = label._getHighlight(at: touch.location(in: label), range: &highlightRange)
            if highlight != nil {
                return false
            }
            return true
        }
        return true
    }
}
