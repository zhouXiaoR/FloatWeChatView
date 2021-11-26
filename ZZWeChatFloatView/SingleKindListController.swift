//
//  SingleKindListControllerViewController.swift
//  ZZWeChatFloatView
//
//  Created by 周晓瑞 on 2018/6/12.
//  Copyright © 2018年 apple. All rights reserved.
//

import UIKit

class SingleKindListController: UIViewController {
     lazy var singleNews: [String] = [String]()
     lazy var tableView = UITableView(frame: view.bounds, style: UITableViewStyle.plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        commitNewsList()
    }

    fileprivate func setUp() {
        tableView.rowHeight = 100.0
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

   fileprivate func commitNewsList() {
        let random = arc4random()%20 + 10
        for  index in 0..<random {
            let titleString = (self.title ?? "") + "\(index)"
            singleNews.append(titleString)
        }
    }
}

extension SingleKindListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = singleNews[indexPath.row]
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singleNews.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newTitlte = singleNews[indexPath.row]
        let detailVC = NewDetailController()
        detailVC.title = newTitlte + "--Web page"
        let colorR: CGFloat = CGFloat(arc4random()%256)
        let colorG: CGFloat  = CGFloat(arc4random()%256)
        let colorB: CGFloat  = CGFloat(arc4random()%256)
        detailVC.themeColor
            = UIColor(red: colorR/256.0, green: colorG/256.0, blue: colorB/256.0, alpha: 1.0)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
