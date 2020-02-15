//
//  LocationInputView.swift
//  myUberClone
//
//  Created by Sheldon on 2/5/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit

class LocationInputView: UIView {
    
    // MARK: Properties
    var delegate : LocationInputViewDelegate?
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1"), for: .normal)
        button.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        return button
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let startLocationPointView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let linkgingView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let destinationPointView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var startingLocatonTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        // Using current location, doesn't allow to change
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        // Add some padding for placeholder or text inside the tf.
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        // The view is always displayed when text field has text.
        tf.leftViewMode = .always
        return tf
        
    }()
    
    lazy var destinationLocatonTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a desination..."
        tf.backgroundColor = .systemGroupedBackground
        // The keyboard will show a search key.
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        
        // Add some padding for placeholder or text inside the tf.
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        // The view is always displayed when text field has text.
        tf.leftViewMode = .always
        
        tf.delegate = self
        return tf
    }()
    
    var user: User? {
        didSet{
            titleLabel.text = user?.fullname
        }
    }
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 44, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 24, height: 25)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        
        addSubview(startingLocatonTextField)
        startingLocatonTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 30)
        
        addSubview(destinationLocatonTextField)
        destinationLocatonTextField.anchor(top: startingLocatonTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 30)
        
        addSubview(startLocationPointView)
        startLocationPointView.centerY(inView: startingLocatonTextField, leftAnchor: leftAnchor,paddingLeft: 20)
        startLocationPointView.setDimensions(height: 6, width: 6)
        // Round it
        startLocationPointView.layer.cornerRadius = 6 / 2
        
        
        addSubview(destinationPointView)
        destinationPointView.centerY(inView: destinationLocatonTextField, leftAnchor: leftAnchor,paddingLeft: 20)
        destinationPointView.setDimensions(height: 6, width: 6)
        
        addSubview(linkgingView)
        linkgingView.centerX(inView: startLocationPointView)
        linkgingView.anchor(top: startLocationPointView.bottomAnchor, left: nil, bottom: destinationPointView.topAnchor, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0.5, height: 0)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Handlers
    @objc func handleBackButton(){
        delegate?.dismissLocationInputView()
    }
    
}

extension LocationInputView : UITextFieldDelegate{
    // According to text to get related suggestion-location
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {return false}
        delegate?.executeSearch(query: text)
        return true
    }
}
