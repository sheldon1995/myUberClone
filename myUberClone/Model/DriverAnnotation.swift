//
//  DriverAnnotation.swift
//  myUberClone
//
//  Created by Sheldon on 2/12/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import MapKit

class DriverAnnotation : NSObject, MKAnnotation{
    // Dynamic variable will change itself according to changes.
    dynamic var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(uid : String, coordinate:CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D){
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
