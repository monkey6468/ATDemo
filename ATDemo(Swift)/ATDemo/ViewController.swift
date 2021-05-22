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
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var textViewConstraintH: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraintB: NSLayoutConstraint!
    
    private var dataArray: [DataModel] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNotify()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeNotify()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ATTextView_Swift";

        textView.atDelegate = self;
        textView.font = k_defaultFont
        textView.attributedTextColor = k_defaultColor
        textView.placeholderTextColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.75)
        textView.placeholder = "我是测试placeholder"
        textView.becomeFirstResponder()
        
        self.initTableView()
    }
    
    //MARK: UI
    func initTableView() -> Void {
        tableView.tableFooterView = UIView.init()
        //
        tableView.register(UINib(nibName: String(describing: TableViewSwiftCell.self)
                                 , bundle: nil),
                           forCellReuseIdentifier: String(describing: TableViewSwiftCell.self))
    }
    
    public func updateUI() -> Void {
        let frame = textView.attributedText.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width-85, height: 0), options: .usesLineFragmentOrigin, context: nil) as CGRect
        var h = frame.size.height
        if h <= 80 {
            h = 80
        }
        textViewConstraintH.constant = h
    }
    
    //MARK: Notify
    func addNotify() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeNotify(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        let user_info = notification.userInfo
        let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if #available(iOS 11.0, *) {
            bottomViewConstraintB.constant = keyboardRect.size.height-self.view.safeAreaInsets.bottom
        } else {
            bottomViewConstraintB.constant = keyboardRect.size.height
        }
        
        let duration = user_info![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        UIView.animate(withDuration: TimeInterval(truncating: duration)) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide(_ notification:Notification){
        bottomViewConstraintB.constant = 0;
        let user_info = notification.userInfo
        let duration = user_info![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        UIView.animate(withDuration: TimeInterval(truncating: duration)) {
            self.view.layoutIfNeeded()
        }
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
        let bindingModel : ATTextViewBinding = ATTextViewBinding(name: user.name, userId: user.userId)
    
        textView.insertText(insertText)
        
        let tmpAString : NSMutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        let range = NSMakeRange(self.textView.selectedRange.location-insertText.count, insertText.count)
        
        tmpAString.setAttributes([
            NSAttributedString.Key.foregroundColor: k_hightColor,
            NSAttributedString.Key.font: k_defaultFont,
            NSAttributedString.Key(rawValue: ATTextBindingAttributeName) : bindingModel
        ], range: range)

        let lastCursorLocation = textView.cursorLocation
        textView.attributedText = tmpAString
        textView.selectedRange = NSMakeRange(lastCursorLocation, textView.selectedRange.length)
        textView.cursorLocation = lastCursorLocation
    }
    
    @IBAction func onActionDone(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        let results = textView.atUserList;

        print("输出打印:");
        for i in 0..<results.count {
            let bindingModel : ATTextViewBinding = results[i]
            print("user info - name:\(String(describing: bindingModel.name))- location:\(String(describing: bindingModel.range?.location))")
        }
        
        let model : DataModel = DataModel()
        model.userList = results
        model.text = textView.text
        dataArray.append(model)
        
        textView.text = nil
        
        self.updateUI()
        textView.typingAttributes = [
            NSAttributedString.Key.font: k_defaultFont,
            NSAttributedString.Key.foregroundColor: k_defaultColor
        ]
        tableView.reloadData()
    }
}

extension ViewController : ATTextViewDelegate {
    func atTextViewDidChange(_ textView: ATTextView) {
        print(textView.text ?? "")

        self.updateUI()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewSwiftCell.self),
                                                 for: indexPath) as! TableViewSwiftCell
        
        let user: DataModel = dataArray[indexPath.row]
        cell.model = user
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let user: DataModel = dataArray[indexPath.row]
        return TableViewSwiftCell.rowHeightWithModel(model: user)
    }
}
