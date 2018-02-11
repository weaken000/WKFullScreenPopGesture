//
//  FullScreenPopViewController.swift
//  WKNavigationControllerPopGestureExample
//
//  Created by yzl on 18/2/10.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class FullScreenPopViewController: UIViewController {

    var isShouldPop: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "全屏返回"
        view.backgroundColor = UIColor.red
        
    }

    override func viewControllerShouldPop() -> Bool {
        
        if !isShouldPop {
            let alert = UIAlertController(title: "", message: "是否执行pop", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "是", style: .default, handler: { (_) in
                _ = self.navigationController?.popToRootViewController(animated: false)
            }))
            present(alert, animated: true, completion: nil)
        }
        
        return isShouldPop
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}
