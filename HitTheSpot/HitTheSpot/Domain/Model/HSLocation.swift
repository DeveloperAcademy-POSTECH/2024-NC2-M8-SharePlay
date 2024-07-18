//
//  HSLocation.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/18/24.
//

import Foundation
import CoreLocation

struct HSLocation: Codable {
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

extension HSLocation {
    func toCLLocation() -> CLLocation {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(from location: HSLocation) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
    
    func distance(from fromLocation: CLLocation) -> CLLocationDistance {
        let toLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
}
