//
//  LoginVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/3/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    // MARK: Properties
    
    let topContainerView : UIView = {
        let topContainerView = UIView()
        let whiteContainerView = UIView()
        let logoImageView =  UIImageView()
        
        // White container view with whit background
        whiteContainerView.addSubview(logoImageView)
        logoImageView.image = #imageLiteral(resourceName: "Uber_Logo_Black")
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        logoImageView.centerX(inView: whiteContainerView)
        logoImageView.centerY(inView: whiteContainerView)
        
        // The whole container view
        topContainerView.addSubview(whiteContainerView)
        whiteContainerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 135, height: 135)
        whiteContainerView.centerX(inView: topContainerView)
        whiteContainerView.centerY(inView: topContainerView)
        
        
        
        whiteContainerView.backgroundColor = .white
        topContainerView.backgroundColor = .systemBlue
        return topContainerView
    }()
    
    let bottomContainerView : UIView = {
        let bottomContainerView = UIView()
        
        let label = UILabel()
        label.text = "Get moving with Uber"
        label.font = UIFont.systemFont(ofSize: 24)
        
        
        let phoneTextField = UITextField()
        phoneTextField.placeholder = "Enter your mobile number"
        phoneTextField.addTarget(self, action: #selector(jumpToPhoneLogin), for: .editingDidBegin)
        // phoneTextField.keyboardType = .phonePad
        
        
        let seperator = UIView()
        seperator.backgroundColor = .gray
        
        let socialAccountButton = UIButton(type: .system)
        socialAccountButton.setTitle("Or connect using a social account", for: .normal)
        socialAccountButton.tintColor = .mainBlue
        socialAccountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        // socialAccountButton.addTarget(self, action: #selector(jumpToPhoneLogin), for: .touchUpInside)
        
        bottomContainerView.addSubview(label)
        label.anchor(top: bottomContainerView.topAnchor, left: bottomContainerView.leftAnchor, bottom: nil, right: bottomContainerView.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        
        bottomContainerView.addSubview(phoneTextField)
        phoneTextField.anchor(top: label.bottomAnchor, left: bottomContainerView.leftAnchor, bottom: nil, right: bottomContainerView.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        
        
        bottomContainerView.addSubview(seperator)
        seperator.anchor(top: phoneTextField.bottomAnchor, left: bottomContainerView.leftAnchor, bottom: nil, right: bottomContainerView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomContainerView.addSubview(socialAccountButton)
        socialAccountButton.anchor(top: seperator.bottomAnchor, left: bottomContainerView.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        
        return bottomContainerView
    }()
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Configure navigation bar.
        configureNavigationBar()
        
        
        // Configure UI of top and bottom container.
        configureUI()
    }
    
    
    // MARK: Handlers
    @objc func jumpToPhoneLogin(){
      let phoneLoginVC = PhoneLoginVC()
//        navigationController?.pushViewController(phoneLoginVC, animated: true)
        
        let navController = UINavigationController(rootViewController: phoneLoginVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: API
    func configureUI(){
        view.addSubview(topContainerView)
        topContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: (view.frame.height * 2) / 3)
        
        view.addSubview(bottomContainerView)
        bottomContainerView.anchor(top: topContainerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // Set navigationBar
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
}
