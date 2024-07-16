//
//  UserLocationUseCase.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/15/24.
//

import SwiftUI
import CoreLocation
import MapKit
import NearbyInteraction

@Observable
class MyInfoUseCase {
    
    enum Action {
        case startMonitorLocation
        case stopMonitorLocation
        case didProfileUpdated(profile: HSUserProfile)
        case didGPSUpdated(location: HSLocation)
    }
    
    struct State {
        var profile: HSUserProfile
        var location: HSLocation? = nil
        var token: NIDiscoveryToken? = nil
    }
    
    private let manager: HSLocationManager
    private(set) var state: State
    
    init(myProfile: HSUserProfile, manager: HSLocationManager) {
        self.state = .init(profile: myProfile)
        self.manager = manager
        self.manager.delegate = self
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .startMonitorLocation:
            manager.startUpdating()
        case .stopMonitorLocation:
            manager.stopUpdating()
        case .didProfileUpdated(let profile):
            state.profile = profile
        case .didGPSUpdated(let location):
            state.location = location
        }
    }
}

extension MyInfoUseCase: HSLocationDelegate {
    func didLocationUpdate(_ location: HSLocation) {
        effect(.didGPSUpdated(location: location))
    }
}
