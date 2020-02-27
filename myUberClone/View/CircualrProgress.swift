//
//  CircualrProgress.swift
//  myUberClone
//
//  Created by Sheldon on 2/26/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit

class CircualrProgress: UIView {
    
    // MARK: Properties
    var progressLayer : CAShapeLayer!
    var trackLayer : CAShapeLayer!
    var pulsatingLayer: CAShapeLayer!
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircleLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Help Functions
    func configureCircleLayers(){
        pulsatingLayer = circleShapeLayer(strokeColor: .clear, fillColor: .mainBlue)
        layer.addSublayer(pulsatingLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .clear, fillColor: .clear)
        layer.addSublayer(trackLayer)
        // The relative location at which to stop stroking the path. Animatable.
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: .systemPink, fillColor: .clear)
        layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
    }
    
    func circleShapeLayer(strokeColor : UIColor, fillColor : UIColor) -> CAShapeLayer{
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 32)
        
        // A path that consists of straight and curved line segments that you can render in your custom views.
        // Start from top
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2.5, startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
        
        // The path defining the shape to be rendered. Animatable.
        layer.path = circularPath.cgPath
        // The color used to stroke the shape’s path. Animatable.
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        // The color used to fill the shape’s path. Animatable.
        layer.fillColor = fillColor.cgColor
        
        layer.lineCap = .round
        
        layer.position = self.center
        return layer
    }
    
    func animatePulsatingLayer(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        // Replace it self
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float, completion: @escaping()->Void){
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        // One is starting point
        animation.fromValue = 1
        // Zero is ending point
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        
        CATransaction.commit()
    }
}
