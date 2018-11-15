//
//  ViewController.swift
//  SliderView
//
//  Created by fashion on 2017/11/11.
//  Copyright © 2017年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var tableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
//        setUpTableView()
        
        
        let headerModel = SliderModel()
        headerModel.slideValue = { (left, right) in
            print("header left\(left) right\((right))")
        }
        let headerView = SliderView(frame: CGRect.init(x: 0, y: 60, width: kScreenWidth, height: 60 * kScaleOn375Width), model: headerModel)
        view.addSubview(headerView)
        
        let footModel = SliderModel()
        footModel.slideValue = { (left, right) in
            print(" foot left\(left) right\(right)")
        }
        let footerView = SliderView(frame: CGRect.init(x: 0, y: 180, width: kScreenWidth, height: 60 * kScaleOn375Width), model: footModel)
        
       view.addSubview(footerView)
        
    }
}




