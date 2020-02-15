//
//  File.swift
//  InstgramClone
//
//  Created by Sheldon on 1/3/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?=nil, left: NSLayoutXAxisAnchor?=nil, bottom: NSLayoutYAxisAnchor?=nil, right: NSLayoutXAxisAnchor?=nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0){
        
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
        // This is the way to activate programmatic constrains
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft :CGFloat=0, constant: CGFloat = 0){
        // This is the way to activate programmatic constrains
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        if let left = leftAnchor{
            anchor(left: left, paddingLeft:paddingLeft)
        }
    }
    
    func setDimensions(height:CGFloat, width:CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addShadow(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
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
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
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
    
    func jumpToMainVC(){
        let homeVC = HomeVC()
        homeVC.configure()
        let navController = UINavigationController(rootViewController: homeVC)
        navController.modalPresentationStyle = .fullScreen
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func uploadUserDataAndJumpToMainVC(currentUid : String, values: [String:Any]){
        USER_REF.child(currentUid).updateChildValues(values) { (error, ref) in
            if let error = error {
                print("DEBUG: Failed to upload user information \(error.localizedDescription)")
                return
            }
            // Jump to main page.
            self.jumpToMainVC()
        }
    }
}


extension MKPlacemark {
    var address: String?{
        get{
            // Additional steet level information
            guard let subThoroughFare = subThoroughfare else {return nil}
            // The street address associated with the placemark.
            guard let thoroughFare = thoroughfare else {return nil}
            // The city associated with the placemark.
            guard let locality = locality else {return nil}
            // The state or province associated with the placemark.
            guard let adminArea = administrativeArea else {return nil}
            
            return "\(subThoroughFare) \(thoroughFare), \(locality), \(adminArea)"
        }
    }
}

extension MKMapView{
    func zoomTofit(annotations: [MKAnnotation]){
        var zoomRect = MKMapRect.null
        annotations.forEach { (annotation) in
            // A point on a two-dimensional map projection.
            let annotationPoint = MKMapPoint(annotation.coordinate)
            // An MKMapRect data structure represents a rectangular area as seen on this two-dimensional map.
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            // Returns a rectangle representing the union of the two rectangles.
            zoomRect = zoomRect.union(pointRect)
        }
        // allowing you to specify additional space around the edges.
        let insets = UIEdgeInsets(top: 120, left: 120, bottom: 290, right: 120)
        setVisibleMapRect(zoomRect,edgePadding: insets, animated: true)
    }
}
