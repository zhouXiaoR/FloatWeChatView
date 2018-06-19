//
//  ConstDefine.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

struct animationConst {
    let animationDuration = 0.5
}

let screenWidth:CGFloat = UIScreen.main.bounds.width
let screenHeight:CGFloat = UIScreen.main.bounds.height
let kWindow = UIApplication.shared.keyWindow

/// 底部黑色视图
let kBottomViewFloatWidth:CGFloat = 160
let kBottomViewFloatHeight:CGFloat = 160
let kBvfMinX = screenWidth - kBottomViewFloatWidth
let kBvMinY = screenHeight - kBottomViewFloatHeight
let kBallRect = CGRect(x: screenWidth-70, y:screenHeight * 0.3, width: 60, height: 60)
let kPadding:CGFloat = 5.0

/// 中间可移动的视图
let kUpBallViewFloatWidth:CGFloat = 60
let kUpBallViewFloatHeight:CGFloat = 60
