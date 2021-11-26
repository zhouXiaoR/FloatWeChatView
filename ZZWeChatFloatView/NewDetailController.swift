//
//  NewDetailController.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

class NewDetailController: UIViewController {
    var themeColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = themeColor ?? UIColor.white

        let switchView = UISwitch()
        switchView.center = view.center
        view.addSubview(switchView)
    }
}
