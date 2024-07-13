//
//  HSLocationDelegate.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/13/24.
//

import Foundation
import CoreLocation

protocol HSLocationDelegate: AnyObject {
    func didLocationUpdate(_ location: CLLocation)
}
