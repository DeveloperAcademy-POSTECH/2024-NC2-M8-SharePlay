//
//  CLLocationCoordinate2D+.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/21/24.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    init(_ coordinate: HSLocation) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
