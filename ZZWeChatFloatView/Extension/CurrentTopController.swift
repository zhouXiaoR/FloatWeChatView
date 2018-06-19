//
//  CurrentTopController.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import Foundation
import UIKit

extension  NSObject{
    func currentViewController() -> UIViewController? {
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else{
            return nil
        }
        
        if vc.isKind(of: UINavigationController.self){
            guard let vc = (vc as! UINavigationController).visibleViewController else{
                return nil
            }
            return vc
        }else if vc.isKind(of: UITabBarController.self){
            guard let vc = (vc as! UITabBarController).selectedViewController else{
                return nil
            }
            return vc
        }
       return  nil
    }

    func currentNavtigationController() -> UINavigationController? {
        return currentViewController()?.navigationController
    }
    
    func currentTabbarController() -> UITabBarController? {
        return currentViewController()?.tabBarController
    }
}
