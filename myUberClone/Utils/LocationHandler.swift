//
//  LocationHandler.swift
//  myUberClone
//
//  Created by Sheldon on 2/11/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import CoreLocation

class LocationHandelr: NSObject, CLLocationManagerDelegate {
    static let shared = LocationHandelr()
    
    var locationManager : CLLocationManager!
    var location : CLLocation?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }
    
    // When users authorize the app for the in-use location service.
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         locationManager.startUpdatingLocation()
         // The accuracy of the location data.
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
     }
}
