//
//  PhoneLoginVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/4/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import Firebase


class PhoneLoginVC: UIViewController {
    
    // MARK: Properties
    let label:UILabel = {
        let label = UILabel()
        label.text = "Enter your mobile number"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    let phoneTextField : UITextField = {
        let phoneTextField = UITextField()
        phoneTextField.placeholder = "(201)555-0123"
        phoneTextField.backgroundColor = .paleBlue
        phoneTextField.keyboardType = .phonePad
        phoneTextField.textContentType = .telephoneNumber
        
        return phoneTextField
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "By continuing you may receive an SMS for verigication. Message and data rates may apply."
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleReceivePhoneNumber))
        navigationController?.navigationBar.tintColor = .black
        
    }
    
    
    
    
    // MARK: Handlers
    @objc func handleReceivePhoneNumber(){
        
        guard let phoneNumber = phoneTextField.text else {return}
        UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
        /*
         Firebase sends an SMS message containing an authentication code to the specified phone number and passes a verification ID to your completion function.
         You will need both the verification code and the verification ID to sign in the user.
         */
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Unable to get secret verification code from firebase: ",error.localizedDescription)
                return
            }
            else{
                // Save the verification ID and restore it when your app loads.
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                // Jump to verify otp page.
                let otpVC = OtpVC()
                self.navigationController?.pushViewController(otpVC, animated: true)
                
                
            }
            
        }
    }
    
    // MARK: API
    func configureUI(){
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
        
        view.addSubview(phoneTextField)
        phoneTextField.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        
        view.addSubview(notificationLabel)
        notificationLabel.anchor(top: phoneTextField.bottomAnchor, left: view.leftAnchor, bottom:nil , right: nil, paddingTop: 150, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 250, height: 0)
    }
    
    
}
