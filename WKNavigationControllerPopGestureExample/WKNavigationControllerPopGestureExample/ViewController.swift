//
//  ViewController.swift
//  WKNavigationControllerPopGestureExample
//
//  Created by yzl on 18/2/10.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let table = UITableView(frame: view.bounds)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        view.addSubview(table)
        
        navigationItem.title = "home"
        navigationItem.leftBarButtonItem = nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "simpleCell")
        }
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "全屏返回"
        }
        else if indexPath.row == 1 {
            cell?.textLabel?.text = "边缘返回"
        }
        else {
            cell?.textLabel?.text = "监控pop动作"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            navigationController?.pushViewController(FullScreenPopViewController(), animated: true)
        }
        else if indexPath.row == 1 {
            navigationController?.pushViewController(BorderPopViewController(), animated: true)
        }
        else {
            let next = FullScreenPopViewController()
            next.isShouldPop = false
            navigationController?.pushViewController(next, animated: true)
        }
    }

}

