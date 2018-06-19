//
//  TransitionPop.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

class TransitionPop: NSObject,UIViewControllerAnimatedTransitioning {
    
    var transitionCtx : UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationConst().animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionCtx = transitionContext
        
        guard  let  fromVC = transitionContext .viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)  else{
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)
        
        let ballRect = FloatViewManager.manager.ballView.frame
        let  startAnimationPath = UIBezierPath(roundedRect: toVC.view.bounds, cornerRadius:0.1)
        let endAnimationPath = UIBezierPath(roundedRect: ballRect, cornerRadius: ballRect.size.height/2)
      
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.path = endAnimationPath.cgPath
        fromVC.view.layer.mask = maskLayer
        
        let basicAniamtion = CABasicAnimation(keyPath: "path")
        basicAniamtion.fromValue = startAnimationPath.cgPath
        basicAniamtion.toValue = endAnimationPath.cgPath
        basicAniamtion.delegate = self
        basicAniamtion.duration = animationConst().animationDuration
        basicAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear) 
        maskLayer.add(basicAniamtion, forKey: "pathAnimation")
    }
}

// MARK: - 动画结束回调
extension TransitionPop : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        transitionCtx?.completeTransition(true)
        transitionCtx?.view(forKey: UITransitionContextViewKey.from)?.layer.mask = nil
        transitionCtx?.view(forKey: UITransitionContextViewKey.to)?.layer.mask = nil
        /// 显示小球
        FloatViewManager.manager.ballView.show = true
    }
}
