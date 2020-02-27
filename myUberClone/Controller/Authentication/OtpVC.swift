//
//  OtpVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/4/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
let phone = UserDefaults.standard.string(forKey: "userPhoneNumber")

class OtpVC: UIViewController {
    // MARK: Properties
    
    
    let label:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = .black
        return label
    }()
    
    let otpTextField : UITextField = {
        let otpTextField = UITextField()
        otpTextField.placeholder = "(201)555-0123"
        otpTextField.backgroundColor = .paleBlue
        // The expectation that a text input area specifies a single-factor SMS login code.
        otpTextField.textContentType = .oneTimeCode
        otpTextField.keyboardType = .phonePad
        return otpTextField
    }()
    
    let didntReceiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I didn't reveive a code", for: .normal)
        button.tintColor = .systemBlue
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleVerifyPhoneNumber))
        navigationController?.navigationBar.tintColor = .black
        
    }
    
    // MARK: Handlers
    @objc func handleVerifyPhoneNumber(){
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return}
        
        // guard let optCode = otpTextField.text else {return}
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: "123456")
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Unable to sign in: ",error.localizedDescription)
                return
            }
            else{
                guard let currentUid = Auth.auth().currentUser?.uid else {return}
                
                USER_REF.observeSingleEvent(of: .value) { (snapshot) in
                    if(snapshot.hasChild(currentUid)){
                        //  jump to container VC 
                        self.jumpToContainerVC()
                    }
                    else{
                        // Jump to information confirmation page.
                        let confirmInformation = ConfirmInformationVC()
                        self.navigationController?.pushViewController(confirmInformation, animated: true)
                    }
                }
                
            }
            
        }
    }
    
    
    // MARK: API
    func configureUI(){
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 120)
        label.text = "Enter the 6-digit code sent to you at \(phone!) "
        
        view.addSubview(otpTextField)
        otpTextField.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        
        view.addSubview(didntReceiveButton)
        didntReceiveButton.anchor(top: otpTextField.bottomAnchor, left: view.leftAnchor, bottom:nil , right: nil, paddingTop: 150, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
    }
    
    
}
