//
//  ListViewController.swift
//  ATDemo(Swift)
//
//  Created by XWH on 2021/5/16.
//

import Foundation
import UIKit

typealias didSelectedBlock = (_ user: User, _ viewController: UIViewController) -> Void // 声明必包

class ListViewController: UIViewController {
    
    var callBack: didSelectedBlock?

    @IBOutlet weak var tableView: UITableView!
    private var dataArray: [User] = []
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView.init()
        self.initData()
    }
    
    func initData() -> Void {
        for i in 0..<10 {
            let user: User = User(name: "测试_\(i+1)_A", userId: i+1)
            dataArray.append(user)
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "testCellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        
        let user: User = dataArray[indexPath.row]
        cell?.textLabel?.text = user.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User = dataArray[indexPath.row]
        self.callBack!(user, self)
    }
}
