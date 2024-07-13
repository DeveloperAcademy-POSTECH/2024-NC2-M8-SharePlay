//
//  CLAuthorizationStatus+.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/13/24.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .authorizedAlways:
            return "Authorized Always"
        @unknown default:
            return "Unknown Authorization Status"
        }
    }
}
