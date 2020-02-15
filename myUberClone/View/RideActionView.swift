//
//  RideActionView.swift
//  myUberClone
//
//  Created by Sheldon on 2/14/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit
class RideActionView: UIView {
    
    
    // MARK: Properties
    var delegate : RideActionViewDelegate?
    
    var destination : MKPlacemark? {
        didSet{
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = " Test Address Title"
        label.textAlignment = .center
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "123 M St, NW Washington DC"
        label.textAlignment = .center
        return label
    }()
    
    lazy var infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        return view
    }()
    
    let uberXLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = " Uber X "
        label.textAlignment = .center
        return label
    }()
    
    let actionButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Confrim UberX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // Without setting the function's parameter as sender, the whole ride action view will animation
        // Rather than a single button.
        button.addTarget(self, action: #selector(handleConfrimRide(sender: )), for: .touchUpInside)
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
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top: infoView.bottomAnchor, paddingTop: 16)
        uberXLabel.centerX(inView: infoView)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: uberXLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4,height: 0.8)
        
        addSubview(actionButton)
        actionButton.anchor(top: separatorView.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Handlers
    @objc func handleConfrimRide(sender: UIButton){
        delegate?.upLoadTrip(self)
        animateView(sender)
    }
    
    func animateView(_ viewToAnimate:UIView){
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            viewToAnimate.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (_) in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
