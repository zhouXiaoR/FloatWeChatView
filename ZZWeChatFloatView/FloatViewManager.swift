//
//  ZZFloatViewManager.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

class FloatViewManager : NSObject {
     static let manager = FloatViewManager()
    
     fileprivate var floatVcClass:[String] = [String]()
     fileprivate var displayLink:CADisplayLink?
     fileprivate var edgeGesture:UIScreenEdgePanGestureRecognizer?
     fileprivate  lazy var bFloatView = BottomFloatView()
     lazy var ballView = FloatBallView()
     lazy var ballRedCancelView = BottomFloatView()
     fileprivate var currentFloatVC:UIViewController?
     fileprivate var tempCurrentFloatVC:UIViewController?
    
    override init() {
        super.init()
        currentNavtigationController()?.interactivePopGestureRecognizer?.delegate = self
        currentNavtigationController()?.delegate = self
        setUp()
        ballMoveEvents()
    }
    
    func setUp() {
        bFloatView.frame = CGRect(x:screenWidth, y: screenHeight, width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)
        kWindow?.addSubview(bFloatView)
        
        ballRedCancelView.frame = CGRect(x:screenWidth, y: screenHeight, width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)
        ballRedCancelView.type = BottomFloatViewType.red
        kWindow?.addSubview(ballRedCancelView)
        
        ballView.frame = kBallRect
        ballView.moveDelegate = self
    }
    
    func ballMoveEvents() {
        // 循环引用
        ballView.ballDidSelect = {
            guard let currentFloatVC = self.currentFloatVC else{
                return
            }
            
            //防止恶意点击
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.currentNavtigationController()?.pushViewController(currentFloatVC, animated: true)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

extension FloatViewManager : UINavigationControllerDelegate {
   
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let curentVC = currentFloatVC else {
            return nil
        }
        
        // 只针对效果VC做动画，其它VC忽略
        if operation == UINavigationControllerOperation.push {
            if  toVC != curentVC{
                return nil
            }
            return TransitionPush()
        } else if operation == UINavigationControllerOperation.pop{
            if fromVC != curentVC{
                return nil
            }
            return TransitionPop()
        } else{
            return nil
        }
    }
}



extension FloatViewManager : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard  let vcs = currentNavtigationController()?.viewControllers else{
            return false
        }
        
        guard vcs.count > 1 else {
            return false
        }
        
        if  let currentVisiableVC = currentViewController() {
             let currentVCClassName = "\(currentVisiableVC.self)"
             if currentVCClassName.contains(floatVcClass.first!){
                startDisplayLink()
                edgeGesture = (gestureRecognizer as? UIScreenEdgePanGestureRecognizer) ?? nil
                tempCurrentFloatVC = currentVisiableVC
            }
        }
        return true
    }
}

extension FloatViewManager{
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkLoop))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func displayLinkLoop() {
        if edgeGesture?.state == UIGestureRecognizerState.changed{
            guard let startP = edgeGesture?.location(in:kWindow) else {
                return
            }
    
            let orx : CGFloat =  max(screenWidth - startP.x, kBvfMinX)
            let ory : CGFloat = max(screenHeight - startP.x, kBvMinY)
            bFloatView.frame = CGRect(x: orx, y: ory, width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)
            
            guard  let transfomBottomP = kWindow?.convert(startP, to: bFloatView) else{
                return
            }
            
         //   print(transfomBottomP)
            if transfomBottomP.x > 0 && transfomBottomP.y > 0{
                let arcCenter = CGPoint(x: kBottomViewFloatWidth, y: kBottomViewFloatHeight)
                let distance = pow((transfomBottomP.x - arcCenter.x),2) + pow((transfomBottomP.y - arcCenter.y),2)
                let onArc = pow(arcCenter.x,2)
                if distance <= onArc{
                    if(!bFloatView.insideBottomSeleted){
                        bFloatView.insideBottomSeleted = true
                    }
                }else{
                    if(bFloatView.insideBottomSeleted){
                        bFloatView.insideBottomSeleted = false
                    }
                }
            }else{
                if(bFloatView.insideBottomSeleted){
                    bFloatView.insideBottomSeleted = false
                }
            }
        }else if(edgeGesture?.state == UIGestureRecognizerState.possible){
            
            if(bFloatView.insideBottomSeleted){
                currentFloatVC = tempCurrentFloatVC
                tempCurrentFloatVC = nil
                ballView.show = true
                
                if let newDetailVC = currentFloatVC as? NewDetailController{
                    ballView.backgroundColor = newDetailVC.themeColor
                }
            }
            
            UIView.animate(withDuration: animationConst().animationDuration, animations: { 
                  self.bFloatView.frame = CGRect(x: screenWidth, y: screenHeight, width: kBottomViewFloatWidth, height:kBottomViewFloatHeight)
            }) { (_) in
                
            }
            stopDisplayLink()
        }
    }
}

extension FloatViewManager : FloatViewDelegate{
    func floatViewBeginMove(floatView: FloatBallView, point: CGPoint) {
        UIView.animate(withDuration: 0.2, animations: { 
             self.ballRedCancelView.frame = CGRect(x:screenWidth - kBottomViewFloatWidth, y: screenHeight - kBottomViewFloatHeight , width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)
        }) { (_) in
            
        }
    }
    
    func floatViewMoved(floatView: FloatBallView, point: CGPoint) {
        
            guard  let transfomBottomP = kWindow?.convert(ballView.center, to: ballRedCancelView) else{
                return
            }
            print(transfomBottomP)
            if transfomBottomP.x > 0 && transfomBottomP.y > 0{
                let arcCenter = CGPoint(x: kBottomViewFloatWidth, y: kBottomViewFloatHeight)
                let distance = pow((transfomBottomP.x - arcCenter.x),2) + pow((transfomBottomP.y - arcCenter.y),2)
                let onArc = pow(arcCenter.x,2)
                if distance <= onArc{
                    if(!ballRedCancelView.insideBottomSeleted){
                        ballRedCancelView.insideBottomSeleted = true
                    }
                }else{
                    if(ballRedCancelView.insideBottomSeleted){
                        ballRedCancelView.insideBottomSeleted = false
                    }
                }
            }else{
                if(ballRedCancelView.insideBottomSeleted){
                    ballRedCancelView.insideBottomSeleted = false
                }
            }
    }
    
    func floatViewCancelMove(floatView: FloatBallView) {
        if(ballRedCancelView.insideBottomSeleted){
            ballView.show = false
            currentFloatVC = nil
            tempCurrentFloatVC = nil
        }
        
        UIView.animate(withDuration: 0.35, animations: { 
            self.ballRedCancelView.frame = CGRect(x:screenWidth, y: screenHeight , width: kBottomViewFloatWidth, height: kBottomViewFloatHeight)
        }) { (_) in
            
        }
    }
}

extension FloatViewManager{
    func addFloatVcsClass(vcs:[String]?){
        guard  let vcs = vcs else {
            return
        }
        
        guard  let vcname = vcs.first else{
            return
        }
        
        floatVcClass.removeAll()
        if !floatVcClass.contains(vcname) {
            floatVcClass.append(vcname)
        }
    }
}

