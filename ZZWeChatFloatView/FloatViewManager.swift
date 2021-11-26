//
//  ZZFloatViewManager.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

final class FloatViewManager: NSObject {

    static let manager = FloatViewManager()

    fileprivate var floatVcClass: [String] = [String]()
    fileprivate var displayLink: CADisplayLink?
    fileprivate var edgeGesture: UIScreenEdgePanGestureRecognizer?
    fileprivate lazy var bFloatView = BottomFloatView()

    lazy var ballView = FloatBallView()
    lazy var ballRedCancelView = BottomFloatView()

    fileprivate var currentFloatViewController: UIViewController?
    fileprivate var tempCurrentFloatVC: UIViewController?

    override init() {
        super.init()
        currentNavigationController()?.interactivePopGestureRecognizer?.delegate = self
        currentNavigationController()?.delegate = self

        setup()
        ballMoveEvents()
    }

    func setup() {
        bFloatView.frame = .init(x: DSFloatChat.screenWidth, y: DSFloatChat.screenHeight, width: DSFloatChat.kBottomViewFloatWidth, height: DSFloatChat.kBottomViewFloatHeight)
        DSFloatChat.kWindow?.addSubview(bFloatView)

        ballRedCancelView.frame = .init(x: DSFloatChat.screenWidth, y: DSFloatChat.screenHeight, width: DSFloatChat.kBottomViewFloatWidth, height: DSFloatChat.kBottomViewFloatHeight)
        ballRedCancelView.type = BottomFloatViewType.red
        DSFloatChat.kWindow?.addSubview(ballRedCancelView)

        ballView.frame = DSFloatChat.kBallRect
        ballView.delegate = self
    }

    func ballMoveEvents() {
        // Circular reference
        ballView.ballDidSelect = {
            guard let currentFloatVC = self.currentFloatViewController else {
                return
            }

            // Prevent malicious clicks
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.currentNavigationController()?.pushViewController(currentFloatVC, animated: true)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

extension FloatViewManager: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let currentViewController = currentFloatViewController else {
            return nil
        }

        // Animate only for effect VCs, ignore other VCs
        if operation == UINavigationControllerOperation.push {
            if toVC != currentViewController {
                return nil
            }
            return TransitionPush()
        } else if operation == UINavigationControllerOperation.pop {
            if fromVC != currentViewController {
                return nil
            }
            return TransitionPop()
        } else {
            return nil
        }
    }
}

extension FloatViewManager: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard  let viewControllers = currentNavigationController()?.viewControllers else {
            return false
        }

        guard viewControllers.count > 1 else {
            return false
        }

        if  let currentVisibleViewController = currentViewController() {
            let currentVCClassName = "\(currentVisibleViewController.self)"
            if currentVCClassName.contains(floatVcClass.first!) {
                startDisplayLink()
                edgeGesture = (gestureRecognizer as? UIScreenEdgePanGestureRecognizer) ?? nil
                tempCurrentFloatVC = currentVisibleViewController
            }
        }
        return true
    }
}

extension FloatViewManager {
    func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkLoop))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }

    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc func displayLinkLoop() {
        if edgeGesture?.state == UIGestureRecognizerState.changed {
            guard let startP = edgeGesture?.location(in: DSFloatChat.kWindow) else {
                return
            }

            let originX: CGFloat = max(DSFloatChat.screenWidth - startP.x, DSFloatChat.kBvfMinX)
            let originY: CGFloat = max(DSFloatChat.screenHeight - startP.x, DSFloatChat.kBvMinY)

            bFloatView.frame = CGRect(x: originX, y: originY, width: DSFloatChat.kBottomViewFloatWidth, height: DSFloatChat.kBottomViewFloatHeight)

            guard  let transformBottomP = DSFloatChat.kWindow?.convert(startP, to: bFloatView) else {
                return
            }

            if transformBottomP.x > .zero && transformBottomP.y > .zero {
                let arcCenter = CGPoint(x: DSFloatChat.kBottomViewFloatWidth, y: DSFloatChat.kBottomViewFloatHeight)
                let distance = pow((transformBottomP.x - arcCenter.x), 2) + pow((transformBottomP.y - arcCenter.y), 2)
                let onArc = pow(arcCenter.x, 2)
                if distance <= onArc {
                    if !bFloatView.insideBottomSelected {
                        bFloatView.insideBottomSelected = true
                    }
                } else {
                    if bFloatView.insideBottomSelected {
                        bFloatView.insideBottomSelected = false
                    }
                }
            } else {
                if bFloatView.insideBottomSelected {
                    bFloatView.insideBottomSelected = false
                }
            }
        } else if edgeGesture?.state == UIGestureRecognizerState.possible {

            if bFloatView.insideBottomSelected {
                currentFloatViewController = tempCurrentFloatVC
                tempCurrentFloatVC = nil
                ballView.show = true

                if let newDetailVC = currentFloatViewController as? NewDetailController {
                    ballView.backgroundColor = newDetailVC.themeColor
                }
            }

            UIView.animate(withDuration: DSFloatChat.animationDuration, animations: {
                self.bFloatView.frame = CGRect(x: DSFloatChat.screenWidth, y: DSFloatChat.screenHeight, width: DSFloatChat.kBottomViewFloatWidth, height: DSFloatChat.kBottomViewFloatHeight)
            }) { (_) in

            }
            stopDisplayLink()
        }
    }
}

extension FloatViewManager: FloatViewDelegate {
    func floatViewBeginMove(floatView: FloatBallView, point: CGPoint) {
        UIView.animate(withDuration: 0.2, animations: {
            self.ballRedCancelView.frame = CGRect(x: DSFloatChat.screenWidth - DSFloatChat.kBottomViewFloatWidth, y: DSFloatChat.screenHeight - DSFloatChat.kBottomViewFloatHeight, width: DSFloatChat.kBottomViewFloatWidth, height: DSFloatChat.kBottomViewFloatHeight)
        }) { (_) in

        }
    }

    func floatViewMoved(floatView: FloatBallView, point: CGPoint) {
        guard  let transformBottomP = DSFloatChat.kWindow?.convert(ballView.center, to: ballRedCancelView) else {
            return
        }

        if transformBottomP.x > .zero && transformBottomP.y > .zero {
            let arcCenter = CGPoint(x: DSFloatChat.kBottomViewFloatWidth, y: DSFloatChat.kBottomViewFloatHeight)
            let distance = pow((transformBottomP.x - arcCenter.x), 2) + pow((transformBottomP.y - arcCenter.y), 2)
            let onArc = pow(arcCenter.x, 2)

            if distance <= onArc {
                if !ballRedCancelView.insideBottomSelected {
                    ballRedCancelView.insideBottomSelected = true
                }
            } else {
                if ballRedCancelView.insideBottomSelected {
                    ballRedCancelView.insideBottomSelected = false
                }
            }
        } else {
            if ballRedCancelView.insideBottomSelected {
                ballRedCancelView.insideBottomSelected = false
            }
        }
    }

    func floatViewCancelMove(floatView: FloatBallView) {
        if ballRedCancelView.insideBottomSelected {
            ballView.show = false
            currentFloatViewController = nil
            tempCurrentFloatVC = nil
        }

        UIView.animate(withDuration: DSFloatChat.animationCancelMoveDuration, animations: {
            self.ballRedCancelView.frame = .init(
                x: DSFloatChat.screenWidth,
                y: DSFloatChat.screenHeight,
                width: DSFloatChat.kBottomViewFloatWidth,
                height: DSFloatChat.kBottomViewFloatHeight
            )
        }) { (_) in

        }
    }
}

extension FloatViewManager {
    func addFloatClass(in viewControllers: [String]?) {
        guard let viewControllers = viewControllers else {
            return
        }

        guard let viewControllerName = viewControllers.first else {
            return
        }

        floatVcClass.removeAll()
        if !floatVcClass.contains(viewControllerName) {
            floatVcClass.append(viewControllerName)
        }
    }
}
