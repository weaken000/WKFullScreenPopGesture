//
//  BorderPopViewController.swift
//  WKNavigationControllerPopGestureExample
//
//  Created by yzl on 18/2/10.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class BorderPopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "边缘返回"
        view.backgroundColor = UIColor.green
        
        let scroll = UIScrollView(frame: view.bounds)
        scroll.contentSize = CGSize(width: 2.0*view.frame.size.width, height: 0)
        let imageView = UIImageView(image: UIImage(named: "banner"))
        imageView.frame = CGRect(x: 0, y: 0, width: 2.0*view.frame.size.width, height: view.frame.size.height)
        scroll.addSubview(imageView)
        view.addSubview(scroll)
        
        scrollViewPopEnable = true
        
    }

    override func viewControllerPopAnimateWillFinished() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
   
}
