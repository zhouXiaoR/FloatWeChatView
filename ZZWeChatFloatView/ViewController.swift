//
//  ViewController.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var tableView = UITableView(frame: view.bounds, style: UITableViewStyle.plain)
    let newsArray = ["科技","生活趣事","娱乐","音乐"]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "微信好友"
        view.backgroundColor = UIColor.red
        
        setUp()
    }
    
   fileprivate func setUp() {
        tableView.rowHeight = 60.0
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = newsArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
        let singleVC = SingleKindListController()
        singleVC.title = newsArray[indexPath.row]
        navigationController?.pushViewController(singleVC , animated: true)
    }
}

