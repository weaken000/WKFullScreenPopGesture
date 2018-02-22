# WKFullScreenPopGesture
swift版本的导航控制器左滑手势返回

### 功能介绍
模仿FDFullScreenPopGesture使用runtime实现全屏返回，同时增加了边缘返回以及返回手势监控

### CocoaPod
    pod 'WKFullScreenPopGesture', '~> 0.1'
### API

在AppDelegate文件中交换方法

    UINavigationController.wk_navigationControllerMethodsSwizzling
    UIViewController.wk_viewControllerMethodsSwizzling

全屏返回默认开启，关闭全屏返回

    popGestrueDisable = true
 
开启边缘返回
 
    scrollViewPopEnable = true
    
监控返回动作，重写方法
    
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
    
    override func viewControllerPopAnimateWillFinished() {
        
    }
