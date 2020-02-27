//
//  PickupVC.swift
//  myUberClone
//
//  Created by Sheldon on 2/15/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit

class PickupVC: UIViewController {
    // MARK: Properties
    
    
    var delegate : PickupVCDelegate?
    
    let mapView = MKMapView()
    
    lazy var circularProgessView : CircualrProgress = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircualrProgress(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 280, width: 280)
        mapView.layer.cornerRadius = 280 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        return cp
    }()
    
    let trip: Trip
    
    let cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handelCancel), for: .touchUpInside)
        return button
    }()
    
    let pickupLabel : UILabel = {
        let label = UILabel()
        label.text = " Would you like to pickup this passenger? "
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    let acceptButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        button.addTarget(self, action: #selector(handelAcceptTrip), for: .touchUpInside)
        return button
    }()
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ViewDidLaod
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        
        self.perform(#selector(animateProgress), with: self, afterDelay: 0.5)
    }
    
    // MARK: Handlers
    
    @objc func handelCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handelAcceptTrip(){
        DriverService.shared.acceptTrips(trip: trip) { (error, reference) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc func animateProgress(){
        circularProgessView.animatePulsatingLayer()
        circularProgessView.setProgressWithAnimation(duration: 5, value: 0) {
            DriverService.shared.updateTripState(self.trip, .rejected) { (err, ref) in
                self.dismiss(animated: true, completion: nil)
            }
        
        }
    }
    // MARK: API
    
    
    // MARK: UI
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func configureUI(){
        view.backgroundColor = .backgroundColor
        
        // Add cancel button
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left:view.leftAnchor, paddingTop: 10, paddingLeft:  16)
        
        // Add map view
        view.addSubview(circularProgessView)
        circularProgessView.setDimensions(height: 360, width: 360)
        circularProgessView.centerX(inView: view)
        circularProgessView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 36)
    
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top:circularProgessView.bottomAnchor, paddingTop: 82)
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
    
    func configureMapView(){
        // A rectangular geographic region centered around a specific latitude and longitude.
        let regin = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(regin, animated: false)
        
        // Add annotation to map view
        self.mapView.addAnnotationAndSelect(forCoordinates: trip.pickupCoordinates)
    }
}
