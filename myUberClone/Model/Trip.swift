//
//  Trip.swift
//  myUberClone
//
//  Created by Sheldon on 2/15/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import UIKit
import MapKit

enum TripState: Int{
    case requested = 0
    case accepted = 1
    case driverArrived = 2
    case inProgress = 3
    case arrivedAtDestination = 4
    case completed = 5
    case rejected = 6
    
}
enum AnnotationType:String{
    case pickup
    case destination
}

struct Trip{
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String!
    var driverUid: String?
    var state: TripState!
    
    init(passengerUid: String, dictionary: [String:Any]) {
        self.passengerUid = passengerUid
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray{
            // A latitude or longitude value specified in degrees.
            guard let latitude = pickupCoordinates[0] as? CLLocationDegrees else {return}
            guard let longitude = pickupCoordinates[1] as? CLLocationDegrees else {return}
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray{
            // A latitude or longitude value specified in degrees.
            guard let latitude = destinationCoordinates[0] as? CLLocationDegrees else {return}
            guard let longitude = destinationCoordinates[1] as? CLLocationDegrees else {return}
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        
        
        if let state = dictionary["state"] as? Int{
            self.state = TripState(rawValue: state)
        }
    }
}
