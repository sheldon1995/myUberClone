//
//  Protocols.swift
//  myUberClone
//
//  Created by Sheldon on 2/5/20.
//  Copyright © 2020 wentao. All rights reserved.
//

import Foundation

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
}


