//
//  ConfirmInformationVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/10/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import Firebase
import GeoFire


class ConfirmInformationVC: UIViewController {
    
    // MARK: Properties
    var location = LocationHandler.shared.locationManager.location
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm your information"
        label.font = UIFont.systemFont(ofSize: 22)
        
        return label
    }()
    
    let nameTextField: UITextField = {
        let tf  = UITextField()
        tf.placeholder = "Input your name"
        tf.backgroundColor = .lightGray
        tf.font = UIFont.systemFont(ofSize: 22)
        // Add some padding for placeholder or text inside the tf.
        let paddingView = UIView()
        paddingView.setDimensions(height: 35, width: 8)
        tf.leftView = paddingView
        // The view is always displayed when text field has text.
        tf.leftViewMode = .always
        return tf
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Input your email"
        tf.backgroundColor = .lightGray
        tf.font = UIFont.systemFont(ofSize: 22)
        let paddingView = UIView()
        paddingView.setDimensions(height: 35, width: 8)
        tf.leftView = paddingView
        // The view is always displayed when text field has text.
        tf.leftViewMode = .always
        return tf
    }()
    
    let passwordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: 22)
        tf.backgroundColor = .lightGray
        tf.isSecureTextEntry = true
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 35, width: 8)
        tf.leftView = paddingView
        // The view is always displayed when text field has text.
        tf.leftViewMode = .always
        return tf
    }()
    
    let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .white
        sc.tintColor = UIColor(white: 0, alpha: 0.8)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    lazy var accountTypeContainerView: UIView = {
        let view = UIView()
        view.addSubview(accountTypeSegmentedControl)
        accountTypeSegmentedControl.anchor(left: view.leftAnchor, right: view.rightAnchor,
                                           paddingLeft: 8, paddingRight: 8)
        accountTypeSegmentedControl.centerY(inView: view, constant: 8)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel,nameTextField,emailTextField,passwordTextField,accountTypeContainerView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 40
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
    }
    
    // MARK: Handlers
    @objc func handleNext(){
        
        guard let name = nameTextField.text else {return}
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        let values = ["email": email,
                      "fullname": name,
                      "phone": phone!,
                      "accountType": accountTypeIndex,
                      "password":password] as [String : Any]
        
        if accountTypeIndex == 1{
            let geofire = GeoFire(firebaseRef: DRIVER_LOCATIONS_REF)
            geofire.setLocation(self.location!, forKey: currentUid) { (error) in
                self.uploadUserDataAndJumpToMainVC(currentUid: currentUid, values: values)
            }
            
        }
        uploadUserDataAndJumpToMainVC(currentUid: currentUid, values: values)
        
        
    }
    
    
    
}
