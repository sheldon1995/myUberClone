//
//  LocationInpurActivationView.swift
//  myUberClone
//
//  Created by Sheldon on 2/5/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit

class LocationInputActivationView: UIView{
    
    // MARK: Properties
    var delegate : LocationInputActivationViewDelegate?
    
    
    // The little point.
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let placeHolerLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        
        return label
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeHolerLabel)
        placeHolerLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MAKR: Handlers
    @objc func presentLocationInputView(){
        delegate?.presentLocationInputView()
    }
}
