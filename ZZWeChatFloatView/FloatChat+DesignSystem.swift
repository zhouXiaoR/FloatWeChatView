//
//  ConstDefine.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

struct DSFloatChat {
    static let animationDuration = 0.5
    static let animationCancelMoveDuration = 0.35

    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let kWindow = UIApplication.shared.keyWindow

    // Bottom black view
    static let kBottomViewFloatWidth: CGFloat = 160
    static let kBottomViewFloatHeight: CGFloat = 160
    static let kBvfMinX = screenWidth - kBottomViewFloatWidth
    static let kBvMinY = screenHeight - kBottomViewFloatHeight
    static let kBallRect = CGRect(x: screenWidth-70, y: screenHeight * 0.3, width: 60, height: 60)
    static let kPadding: CGFloat = 5.0

    // Movable view in the middle
    static let kUpBallViewFloatWidth: CGFloat = 60
    static let kUpBallViewFloatHeight: CGFloat = 60
}
