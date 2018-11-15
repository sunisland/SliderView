//
//  SliderView.swift
//  SliderView
//
//  Created by fashion on 2017/11/11.
//  Copyright © 2017年 shangZhu. All rights reserved.
//

import UIKit




private let screenWidth = UIScreen.main.bounds.size.width
private let scrrenHeight = UIScreen.main.bounds.size.height
private let scaleW = screenWidth / 375.0
private let scaleH = scrrenHeight / 667.0

//    private  let scaleH : CGFloat = {
//           return (self.scrrenHeight / 667.0)
//        }
// UIControl是UIView的子类, 是UIKit框架中可交互的控件的基类
// UIButton、UISwitch、UITextField等都是`UIControl`子类
class SliderView: UIControl {

    private var leftSliderLayer : CALayer!
    private var rightSliderLayer : CALayer!
    private var leftTracking : Bool = false
    private var rightTracking: Bool = false
    private var previousLocation : CGFloat = 0
    private var currentLeftValue : CGFloat = 0
    private var currentRightValue : CGFloat = 0
    private var scaleValue : CGFloat = 0
    
    private var rightMaxX : CGFloat = 0  // 右侧最大能滑动到的X
    private var leftMinX : CGFloat = 0  // 左侧最小能滑动到的x
    
    private var model : SliderModel?
    
    private lazy var normalBackImageView : UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "quickrent_price_white")?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 4))
        imageV.layer.cornerRadius = 4
        return imageV
    }()
    private lazy var highlightedBackImageView : UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "quickrent_price_redrec")?.stretchableImage(withLeftCapWidth: 10, topCapHeight: 4))
        imageV.layer.cornerRadius = 4
        return imageV
    }()
    
    
//    convenience init(frame: CGRect, MaxValue: Int, MinValue: Int) {
//        let model = SliderModel()
//        self.init(frame: frame, model: model)
//    }
    
     init(frame: CGRect, model : SliderModel) {
        super.init(frame: frame)
        self.model = model
        currentLeftValue = model.leftDefault
        currentRightValue = model.rightDefault
        
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTextLayer() -> CATextLayer {
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.fontSize = 12
        layer.foregroundColor = UIColor.red.cgColor
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.alignmentMode = kCAAlignmentCenter
        return layer
    }
    
    private func createSliderLayer(imageName:String) -> CALayer {
        let layer = CALayer()
        layer.contents = UIImage(named: imageName)?.cgImage
        return layer
    }
    
    private func setUpSubviews() {
        
        // 实际可滑动区域是 bar 的0点到bar的宽度-滑块的宽度
        let leftSliderX = model!.barLeftMarge
        // 右边最大的X要减去距离右边的距离, 还有减去一个滑块的宽度
        let rightSliderX = self.frame.width - model!.barRightMarge - model!.sliderW
        
        rightMaxX = rightSliderX
        leftMinX = leftSliderX
        
        let kBarWidth =  rightSliderX - leftSliderX + model!.sliderW
        guard kBarWidth != 0 else {
            print("**************************** 错误 barWidth 是零")
            return
        }
        let v = fabs(model!.maxVaule - model!.minValue)
        guard  Int(v) != 0 else {
            print("**************************** 错误 最大值和最小值相同")
            return
        }
        // 宽度和值的比例
        scaleValue = fabs(model!.maxVaule - model!.minValue) / (rightSliderX - leftSliderX )
        
        // 左边默认的距离
        let leftPeed : CGFloat = fabs(model!.leftDefault - model!.minValue) / scaleValue
        // 右边默认值的距离
        let rightPeed : CGFloat = fabs(model!.maxVaule - model!.rightDefault) / scaleValue
        // 左边滑块
        leftSliderLayer = CALayer()
        leftSliderLayer.contents = model?.leftPointImg
        layer.addSublayer(leftSliderLayer)
        leftSliderLayer.frame = CGRect.init(x: leftSliderX + leftPeed, y: 0.5 * (frame.height - model!.sliderH) + 5 * scaleW, width: model!.sliderW, height: model!.sliderH)
        
       //右边滑块
        rightSliderLayer = CALayer()
        rightSliderLayer.contents = model?.rightPointImg
        layer.addSublayer(rightSliderLayer)
        rightSliderLayer.frame = CGRect.init(x: rightSliderX - rightPeed, y: leftSliderLayer.frame.minY, width: model!.sliderW, height: model!.sliderH)
        //
        normalBackImageView.tintColor = model!.barNormalColor
        highlightedBackImageView.tintColor = model!.barSelectColor
        addSubview(normalBackImageView)
        addSubview(highlightedBackImageView)
        
        let barY = leftSliderLayer.frame.minY + 0.5 * (model!.sliderH - model!.sliderBarHeight)
        normalBackImageView.frame = CGRect.init(x: leftSliderX, y: barY, width: kBarWidth, height: model!.sliderBarHeight)
        insertSubview(normalBackImageView, at: 0)
        
        let highBarW = rightSliderLayer.frame.minX - leftSliderLayer.frame.minX
        highlightedBackImageView.frame = normalBackImageView.frame
        highlightedBackImageView.frame = CGRect(x: leftSliderLayer.frame.minX, y: barY, width: highBarW, height: model!.sliderBarHeight)
        
        insertSubview(highlightedBackImageView, at: 1)
    }
}

extension SliderView {
    // UIControl 提供了一些方法来跟踪触摸
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let locationPoint = touch.location(in: self)
        previousLocation = locationPoint.x
        leftTracking = leftSliderLayer.frame.contains(locationPoint)
        rightTracking = rightSliderLayer.frame.contains(locationPoint)
        return leftTracking || rightTracking
    }
    // 你可能注意到当在移动滑块时，可以在控件之外的范围对其拖拽，然后手指回到控件内，也不会丢失跟踪。其实这在小屏幕的设备上，是非常重要的一个功能。
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let currentLocation = touch.location(in: self).x
        
        if leftTracking {
            
            // 设置 CATransaction 中的 disabledActions。这样可以确保每个 layer 的frame 立即得到更新，并且不会有动画效果
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let speed = currentLocation - previousLocation
            previousLocation = currentLocation
            leftSliderLayer.frame.origin.x = max(leftSliderLayer.frame.origin.x + speed, leftMinX)
           // 记录当前的值
            currentLeftValue =  (leftSliderLayer.frame.minX - leftMinX) * scaleValue
            updateSliderBarFunc()
            CATransaction.commit()
            // 将值传出
            updateSliderValue()
            return true
        } else if rightTracking {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let speed = currentLocation - previousLocation
            previousLocation = currentLocation
            rightSliderLayer.frame.origin.x = min(rightSliderLayer.frame.origin.x + speed, rightMaxX  )
            currentRightValue = (rightSliderLayer.frame.minX - leftMinX)  * scaleValue
            updateSliderBarFunc()
            CATransaction.commit()
            // 将值传出
            updateSliderValue()
            return true
        }
        return false
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        leftTracking = false
        rightTracking = false
    }
    
    private func updateSliderBarFunc() {
        highlightedBackImageView.frame = CGRect.init(x: leftSliderLayer.frame.origin.x + 0.5 * model!.sliderW, y: highlightedBackImageView.frame.origin.y, width: rightSliderLayer.frame.origin.x - leftSliderLayer.frame.origin.x, height: model!.sliderBarHeight)
        
        
    }
    private func updateSliderValue() {
        if let block = model?.slideValue{
            let l = ceilf(Float(currentLeftValue))
            let r = ceilf(Float(currentRightValue))
            block(l, r)
        }
        
     
    }
}

