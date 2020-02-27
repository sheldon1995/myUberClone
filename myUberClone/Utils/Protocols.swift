//
//  Protocols.swift
//  myUberClone
//
//  Created by Sheldon on 2/5/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import Foundation
import Firebase

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}


protocol LocationInputActivationViewDelegate {
    func presentLocationInputView()
}

protocol LocationInputViewDelegate {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

protocol HomeControllerDelegate: class {
    func handleMenuToggle()
}

protocol MenuControllerDelegate: class {
    func didSelect(option: MenuOptions)
}

protocol RideActionViewDelegate: class {
    func upLoadTrip(_ view:RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
    
}

protocol PickupVCDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

protocol AddLocationVCDelegate:class {
    func uploadLocation(type:LocationType, locationString: String)
}


protocol SettingVCDelegate:class {
    func updateUser(_ controller: SettingVC)
}
