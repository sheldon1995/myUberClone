//
//  RideActionView.swift
//  myUberClone
//
//  Created by Sheldon on 2/14/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit

enum RideActionViewConfiguration{
    case requestRide
    case tripAccepted
    case pickupPassenger
    case driverArrived
    case tripInProgress
    case endTrip
    init(){
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String{
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    init(){
        self = .requestRide
    }
}

class RideActionView: UIView {
    
    
    // MARK: Properties
    var user:User?
    
    var delegate : RideActionViewDelegate?
    
    var destination : MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var config = RideActionViewConfiguration(){
        didSet{
            configureUI(withConfig: config)
        }
        
    }
    var buttonAction = ButtonAction()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    lazy var infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()
    
    let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = " Uber X "
        label.textAlignment = .center
        return label
    }()
    
    let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Confrim UberX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // Without setting the function's parameter as sender, the whole ride action view will animation
        // Rather than a single button.
        button.addTarget(self, action: #selector(handleActionButton(sender: )), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        return button
    }()
    
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.spacing = 2
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor,paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: stack)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 15)
        
        addSubview(uberInfoLabel)
        uberInfoLabel.anchor(top: infoView.bottomAnchor, paddingTop: 16)
        uberInfoLabel.centerX(inView: infoView)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberInfoLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4,height: 0.8)
        
        addSubview(actionButton)
        actionButton.anchor(top: separatorView.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Handlers
    @objc func handleActionButton(sender: UIButton){
        switch buttonAction {
        case .requestRide:
            delegate?.upLoadTrip(self)
            print("DEBUG: upload")
        case .cancel:
            delegate?.cancelTrip()
            print("DEBUG: cancel")
        case .getDirections:
            print("DEBUG: getDirections")
        case .pickup:
            delegate?.pickupPassenger()
            print("DEBUG: pickup")
        case .dropOff:
            delegate?.dropOffPassenger()
            print("DEBUG: dropOff")
            
        }
        animateView(sender)
    }
    
    // Animation for action button.
    func animateView(_ viewToAnimate:UIView){
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    // MARK: UI
    func configureUI(withConfig config: RideActionViewConfiguration){
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else {return}
            if user.accountType == .passenger {
                titleLabel.text = "En Route To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            else{
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
        case .driverArrived:
            guard let user = user else {return}
            if user.accountType == .driver{
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
            
            
        case .pickupPassenger:
            titleLabel.text = "Arrived at Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else {return}
            if user.accountType == .driver{
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            }
            else{
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        case .endTrip:
            guard let user = user else {return}
            
            if user.accountType == .driver{
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            }
            else{
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "Arrived At Destination"
            addressLabel.text = ""
        }
    }
    
}
