//
//  ViewController.swift
//  ATDemo
//
//  Created by XWH on 2021/5/15.
//

import UIKit

let k_defaultColor = UIColor.blue

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: ATTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.atDelegate = self;
        textView.font = k_defaultFont;
        textView.attributed_TextColor = k_defaultColor;
    }
    
    @IBAction func onActionInsert(_ sender: UIButton) {
        
        let name = "测试ABC"
        let insertText = "@"+name+" "
        let bindingModel : TextViewBinding = TextViewBinding(name: name, userId: 23)
    

        textView.insertText(insertText)
        
        let tmpAString : NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let range = NSMakeRange(self.textView.selectedRange.location-insertText.count, insertText.count)
        
        tmpAString.setAttributes([
            NSAttributedString.Key.foregroundColor: k_hightColor,
            NSAttributedString.Key.font: k_defaultFont,
            NSAttributedString.Key(rawValue: TextBindingAttributeName) : bindingModel
        ], range: range)

        let lastCursorLocation = textView.cursorLocation
        textView.attributedText = tmpAString
        textView.selectedRange = NSMakeRange(lastCursorLocation, textView.selectedRange.length)
        textView.cursorLocation = lastCursorLocation
    }
    @IBAction func onActionShow(_ sender: UIButton) {
        
        let results = textView.atUserList;

        print("输出打印:");
        for i in 0..<results.count {
            let bindingModel : TextViewBinding = results[i]
            print("user info - name:\(String(describing: bindingModel.name))- location:\(String(describing: bindingModel.range?.location))")
        }
    }
}

extension UIViewController : ATTextViewDelegate {
    func atTextViewDidChange(_ textView: ATTextView) {
        print(textView.text ?? "")
    }
}
