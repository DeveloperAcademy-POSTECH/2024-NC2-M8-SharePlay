//
//  ShareLocationMessage.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/19/24.
//

import Foundation
import CoreLocation

struct ShareLocationMessage: Codable, Identifiable {
    var id = UUID()
    var userName: String
    let location: LocationCoordinate
}

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(_ location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}

extension LocationCoordinate {
    func toCLLocation() -> CLLocation {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(from location: LocationCoordinate) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
    
    func distance(from fromLocation: CLLocation) -> CLLocationDistance {
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
}
