//
//  UINavigationControllerPopGesture.swift
//  WashHelper
//
//  Created by yzl on 18/1/12.
//  Copyright © 2018年 lwk. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct AssociatedKey {
    static var viewWillAppearInjectBlock    = 0
    static var navigationBarHidden          = 0
    static var popGestrueEnable             = 0
    static var scrollViewPopEnable          = 0
    static var navigationBarBackgroundColor = 0
    static var navigationBarTitleColor      = 0
    static var gestureDelegate              = 0
    static var popGestureRecognizer         = 0
    static var topVC                        = 0
}

class WKNavigationControllerPopGeustureDelegate: NSObject, UIGestureRecognizerDelegate {
    
    fileprivate weak var navigationController: UINavigationController?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        guard let navi = navigationController else {
            return false
        }
        
        if let lastVC = navi.viewControllers.last, lastVC.popGestrueDisable == true {
            return false
        }
        
        if (navi.value(forKey: "_isTransitioning") as! Bool) == true {
            return false
        }
        
        //控制器存在scrollView，开启边缘返回
        if let lastVC = navi.viewControllers.last, lastVC.scrollViewPopEnable == true {
            if (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view).x > 0, gestureRecognizer.location(in: gestureRecognizer.view).x <= 60 {
                return lastVC.viewControllerShouldPop()
            }
            return false
        }
        //默认全屏返回
        else if let lastVC = navi.viewControllers.last, lastVC.scrollViewPopEnable == false {
            if (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view).x <= 0 {
                return false
            }
        }
        
        if let lastVC = navi.viewControllers.last {
            return lastVC.viewControllerShouldPop()
        }
        else {
            return true
        }
    }
    //手势冲突时，同时获得冲突手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    //只有当前手势失败时，才能执行其他手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension UINavigationController {
    
    fileprivate var popGestureRecognizer: UIPanGestureRecognizer {
        get {
            var gesture = objc_getAssociatedObject(self, &AssociatedKey.popGestrueEnable) as? UIPanGestureRecognizer
            if gesture == nil {
                gesture = UIPanGestureRecognizer()
                gesture?.maximumNumberOfTouches = 1
                objc_setAssociatedObject(self, &AssociatedKey.popGestrueEnable, gesture!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return gesture!
        }
    }
    
    fileprivate var currentVC: UIViewController? {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.topVC, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.topVC) as? UIViewController
        }
    }
    
    private var popGestureRecognizerDelegate: WKNavigationControllerPopGeustureDelegate {
        get {
            var delegate = objc_getAssociatedObject(self, &AssociatedKey.gestureDelegate) as? WKNavigationControllerPopGeustureDelegate
            if delegate == nil {
                delegate = WKNavigationControllerPopGeustureDelegate()
                objc_setAssociatedObject(self, &AssociatedKey.gestureDelegate, delegate!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            delegate?.navigationController = self
            return delegate!
        }
    }
    
    open static let wk_navigationControllerMethodsSwizzling: () = {
        guard let orginMethod = class_getInstanceMethod(UINavigationController.self, #selector(pushViewController(_:animated:))), let swizzMethod = class_getInstanceMethod(UINavigationController.self, #selector(wk_pushViewController(_:animated:))) else {
            return
        }
        method_exchangeImplementations(orginMethod, swizzMethod)
    }()
    
    @objc private func wk_pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(popGestureRecognizer) == false {
            
            popGestureRecognizer.delegate = popGestureRecognizerDelegate
            interactivePopGestureRecognizer?.isEnabled = false
            
            let internalTargets = interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject]
            let internalTarget = internalTargets?.first?.value(forKey: "target") as? NSObject
            let internalAction = NSSelectorFromString("handleNavigationTransition:")
            if let target = internalTarget {
                popGestureRecognizer.addTarget(target, action: internalAction)
            }
            interactivePopGestureRecognizer?.view?.addGestureRecognizer(popGestureRecognizer)
            
        }
        
        setupViewWillAppearInject(viewController)
        currentVC = viewController
        wk_pushViewController(viewController, animated: animated)
    }
    
    private func setupViewWillAppearInject(_ viewController: UIViewController) {
        let injectObj = viewWillAppearInjectObject { [weak self] (vc, animated) in
            if  let `self` = self {
                self.setNavigationBarHidden(vc.navigationBarHidden, animated: animated)
                self.navigationBar.barTintColor = vc.navigationBarColor
            }
        }

        viewController.viewControllerWillAppearInjectBlock = injectObj
        if let lastVC = viewControllers.last, lastVC.viewControllerWillAppearInjectBlock == nil {
            lastVC.viewControllerWillAppearInjectBlock = injectObj
        }
    }
    
}

extension UINavigationController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        guard let topVC = self.topViewController else {
            return
        }
        
        guard let coor = topVC.transitionCoordinator else {
            return
        }
        
        coor.animate(alongsideTransition: nil) { [weak self, weak viewController] (ctx) in
            if let `self` = self, let vc = viewController, let cur = self.currentVC {
                if ctx.isCancelled == false {
                    if cur != vc {
                        cur.viewControllerPopAnimateWillFinished()
                        self.currentVC = vc
                    }
                }
            }
        }
    }
    
    //导航栏完成push或者pop
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
}

extension UIViewController {
    
    //闭包不属于AnyObject,需要先转换,并且要与OC相同，需要对block添加@convince(block), 或者直接使用class类型封装闭包
    var viewControllerWillAppearInjectBlock: viewWillAppearInjectObject? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.viewWillAppearInjectBlock) as? viewWillAppearInjectObject
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.viewWillAppearInjectBlock, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var navigationBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.navigationBarHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.navigationBarHidden, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var popGestrueDisable: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.popGestrueEnable) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.popGestrueEnable, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var scrollViewPopEnable: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.scrollViewPopEnable) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.scrollViewPopEnable, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var navigationBarColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.navigationBarBackgroundColor) as? UIColor ?? kMainColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.navigationBarBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var navigationBarTitleColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.navigationBarTitleColor) as? UIColor ?? UIColor.white
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.navigationBarTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //是否需要返回
    @discardableResult
    func viewControllerShouldPop() -> Bool {
        return true
    }
    //pop手势动作即将完成，导航栏返回动作即将完成
    func viewControllerPopAnimateWillFinished() {
        
    }
    
    open static let wk_viewControllerMethodsSwizzling: () = {
        guard let originalViewWillAppearSelector = class_getInstanceMethod(UIViewController.self, #selector(viewWillAppear(_:))),
            let swizzledViewWillAppearSelector = class_getInstanceMethod(UIViewController.self, #selector(wk_viewWillAppear(_:))) else {
                return
        }
        method_exchangeImplementations(originalViewWillAppearSelector, swizzledViewWillAppearSelector)
    }()
    
    @objc fileprivate func wk_viewWillAppear(_ animated: Bool) {
        wk_viewWillAppear(animated)
        if let appearObj = self.viewControllerWillAppearInjectBlock, let appear = appearObj.block {
            appear(self, animated)
        }
    }
}

class viewWillAppearInjectObject: NSObject {
    var block: ((_ viewController: UIViewController, _ animated: Bool) -> Void)?
    
    init(_ block: ((_ viewController: UIViewController, _ animated: Bool) -> Void)?) {
        self.block = block
    }
}


