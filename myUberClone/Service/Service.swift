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

// MARK: Driver Service
struct DriverService {
    static let shared = DriverService()
    func observeTrips(completion: @escaping(Trip) -> Void){
        // Whenever a trip is added we want to listen to it.
        TRIPS_REF.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            // Construct trip
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
            
        }
    }
    
    func observeTripCanceled(_ trip: Trip, completion: @escaping() -> Void){
        
        TRIPS_REF.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { (snapshot) in
            completion()
        }
        
    }
    
    func acceptTrips(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUid":uid,"state":TripState.accepted.rawValue] as [String : Any]
        TRIPS_REF.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateTripState(_ trip:Trip, _ state:TripState, completion: @escaping(Error?,DatabaseReference) -> Void){
        TRIPS_REF.child(trip.passengerUid).child("state").setValue(state.rawValue,withCompletionBlock: completion)
        // When the trip is completed, remove all observers.
        if state == .completed {
            TRIPS_REF.child(trip.passengerUid).removeAllObservers()
        }
    }
    
    
    func updateDriverLocation(location: CLLocation){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geofire = GeoFire(firebaseRef: DRIVER_LOCATIONS_REF)
        geofire.setLocation(location, forKey: uid)
    }
    
    
    
}
// MARK: Passenger Service
struct PassengerService {
    static let shared = PassengerService()
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
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let pickupArray = [pickupCoordinates.latitude,pickupCoordinates.longitude]
        let destinationArray = [destination.latitude,destination.longitude]
        let values = ["pickupCoordinates":pickupArray,"destinationCoordinates":destinationArray,"state": TripState.requested.rawValue] as [String : Any]
        TRIPS_REF.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func obserCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        TRIPS_REF.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            // Construct trip
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
            // Dissmiss loading view
        }
    }
    
    func deleteTrip(completion: @escaping(Error?, DatabaseReference)->Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        TRIPS_REF.child(uid).removeValue(completionBlock: completion)
    }
    
    func saveLocation(type:LocationType, locationString: String, completion: @escaping(Error?,DatabaseReference) ->Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let key: String = type == .home ? "homeLocation" : "workLocation"
        USER_REF.child(uid).child(key).setValue(locationString,withCompletionBlock: completion)
        
    }
}

// MARK: Shared Service
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
    
}
