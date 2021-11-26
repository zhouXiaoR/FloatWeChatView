//
//  FloatBallView.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/14.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

protocol FloatViewDelegate: NSObjectProtocol {
    func floatViewBeginMove(floatView: FloatBallView, point: CGPoint)
    func floatViewMoved(floatView: FloatBallView, point: CGPoint)
    func floatViewCancelMove(floatView: FloatBallView)
}

class FloatBallView: UIView {

    weak var delegate: FloatViewDelegate?
    var ballDidSelect : (() -> Void)?

    fileprivate var beginPoint: CGPoint?

    var show: Bool = false {
        didSet {
            if show {
                DSFloatChat.kWindow?.addSubview(self)
                self.alpha = 0.0
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 1.0
                }
            } else {
                self.alpha = 1.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 0.0
                }) { (_) in
                    // self.removeFromSuperview()
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        addGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width * 0.5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension FloatBallView {
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        tap.delaysTouchesBegan = true
        addGestureRecognizer(tap)
    }

    func setUp() {
        backgroundColor = UIColor.black
        layer.masksToBounds = true
        alpha = 0.0
    }
}

fileprivate extension FloatBallView {
    @objc func tapGesture() {
       guard let ballDidSelect = ballDidSelect else {
           return
        }
         ballDidSelect()
    }
}

// MARK: - Gesture move

extension FloatBallView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginPoint = touches.first?.location(in: self)
        if let beginPoint = beginPoint {
            delegate?.floatViewBeginMove(floatView: self, point: beginPoint)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentPoint = touches.first?.location(in: self)

        guard let currentP = currentPoint, let beginP = beginPoint else {
            return
        }

        delegate?.floatViewMoved(floatView: self, point: currentP)

        let offsetX = currentP.x - beginP.x
        let offsetY = currentP.y - beginP.y
        center = CGPoint(x: center.x + offsetX, y: center.y + offsetY)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let superview = superview else { return }

        delegate?.floatViewCancelMove(floatView: self)

        let  marginLeft = frame.origin.x
        let  marginRight = superview.frame.width - frame.minX - frame.width
        let  marginTop = frame.minY
        let  marginBottom = superview.frame.height - self.frame.minY - frame.height

        var destinationFrame = frame

        var tempX: CGFloat = .zero

        if marginTop < 60 {
            if marginLeft < marginRight {
                if marginLeft < DSFloatChat.kPadding {
                    tempX = DSFloatChat.kPadding
                } else {
                    tempX = frame.minX
                }
            } else {
                if marginRight < DSFloatChat.kPadding {
                    tempX = superview.frame.width - frame.width - DSFloatChat.kPadding
                } else {
                    tempX = frame.minX
                }
            }
            destinationFrame = CGRect(x: tempX, y: DSFloatChat.kPadding, width: DSFloatChat.kBallRect.width, height: DSFloatChat.kBallRect.height)
        } else if marginBottom < 60 {
            if marginLeft < marginRight {
                if marginLeft < DSFloatChat.kPadding {
                    tempX = DSFloatChat.kPadding
                } else {
                    tempX = frame.minX
                }
            } else {
                if marginRight < DSFloatChat.kPadding {
                    tempX = superview.frame.width - frame.width - DSFloatChat.kPadding
                } else {
                    tempX = frame.minX
                }
            }
            destinationFrame = CGRect(x: tempX, y: superview.frame.height - frame.height-DSFloatChat.kPadding, width: DSFloatChat.kBallRect.width, height: DSFloatChat.kBallRect.height)
        } else {
            destinationFrame = CGRect(x: marginLeft < marginRight ? DSFloatChat.kPadding:superview.frame.width - frame.width-DSFloatChat.kPadding, y: frame.minY, width: DSFloatChat.kBallRect.width, height: DSFloatChat.kBallRect.height)
        }

        UIView.animate(withDuration: DSFloatChat.animationDuration, animations: {
            self.frame = destinationFrame
        }) { (_) in

        }
    }
}
