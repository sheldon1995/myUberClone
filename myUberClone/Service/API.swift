//
//  API.swift
//  myUberClone
//
//  Created by Sheldon on 2/8/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire
// Constants

let DB_REF = Database.database().reference()


let USER_REF = DB_REF.child("users")

let DRIVER_LOCATIONS_REF = DB_REF.child("driver-locations")

let TRIPS_REF = DB_REF.child("trips")
struct Service {
    static let shared = Service()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchDriverData(location: CLLocation,completion: @escaping(User) -> Void){
        
        let geofire = GeoFire(firebaseRef: DRIVER_LOCATIONS_REF)
        DRIVER_LOCATIONS_REF.observe(.value) { (snapshot) in
            // Kilimeters
            // Observe(), every time make changes, listen to this change.
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                Service.shared.fetchUserData(uid: uid, completion: { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                })
            })
        }
    }
    
    func uploadTrip(_ pickupCoordinates:CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void){
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let pickupArray = [pickupCoordinates.latitude,pickupCoordinates.longitude]
//        let destinationArray = [destination.latitude,destination.longitude]
//        let values = ["pickupCoordinates":pickupArray,"destinationCoordinates":destinationArray,"state": TripState.requested.rawValue] as [String : Any]
//        TRIPS_REF.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
}
