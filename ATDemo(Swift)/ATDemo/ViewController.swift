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
        
        navigationItem.title = "ATTextView_Swift";

        textView.atDelegate = self;
        textView.font = k_defaultFont
        textView.attributed_TextColor = k_defaultColor;
        
    }
    
    @IBAction func pushListVC(_ sender: UIButton) {
        let storyboard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
        let vc: ListViewController! = storyboard?.instantiateViewController(withIdentifier: "ListViewController") as? ListViewController
        let nav : UINavigationController = UINavigationController(rootViewController: vc) as UINavigationController
        self.present(nav, animated: true, completion: nil)
        
        vc.callBack = { (user: User, viewController: UIViewController) in
            
            viewController.dismiss(animated: true, completion: nil)
            
            self.onActionInsert(user)
        }
    }
    
    func onActionInsert(_ user: User) {
        let insertText = "@" + user.name! + " "
        let bindingModel : TextViewBinding = TextViewBinding(name: user.name, userId: user.userId)
    
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
