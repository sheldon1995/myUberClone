//
//  File.swift
//  InstgramClone
//
//  Created by Sheldon on 1/3/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        
        // This is the way to activate programmatic constrains
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView, constant: CGFloat = 0){
        centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, constant: CGFloat = 0){
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
    }
}


let keyWindow = UIApplication.shared.connectedScenes
    .filter({$0.activationState == .foregroundActive})
    .map({$0 as? UIWindowScene})
    .compactMap({$0})
    .first?.windows
    .filter({$0.isKeyWindow}).first



extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let mainBlue = rgb(red: 0, green: 137, blue: 249)
    static let disableColor = rgb(red: 149, green: 204, blue: 244)
    static let enableColor = rgb(red: 17, green: 154, blue: 237)
    static let myLightGray = rgb(red: 230, green: 230, blue: 230)
    static let mygray = rgb(red: 240, green: 240, blue: 240)
    static let paleBlue = rgb(red: 175, green: 238, blue: 238)
}

extension UIViewController{
    func hideKeyboardWhenTapped(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRetractKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func handleRetractKeyboard(){
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
}
