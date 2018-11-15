//
//  SliderModel.swift
//  SliderView
//
//  Created by 陈春林 on 2018/11/14.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class SliderModel: NSObject {
    var maxVaule : CGFloat = 100
    var minValue : CGFloat = 0
    var leftDefault : CGFloat = 0
    var rightDefault : CGFloat = 100
    
    var sliderBarHeight : CGFloat = 10   // slider高度
    var barLeftMarge : CGFloat = 30  // bar 距离左边间接
    var barRightMarge  : CGFloat =  30 // bar 距离右边间接
    
//    var pointWH : CGFloat = 20.0 // 滑块的宽高
    var sliderW : CGFloat = 20.0 // 滑块的宽
    var sliderH : CGFloat = 20.0 // 滑块的高
    
    
    var leftPointImg : CGImage = (UIImage(named: "price")?.cgImage)!
    var rightPointImg : CGImage = (UIImage(named: "price")?.cgImage)!
    
    var barNormalColor : UIColor = UIColor.green
    var barSelectColor : UIColor = UIColor.yellow
    
    var slideValue : ((Float ,  Float) -> ())?
    
}
