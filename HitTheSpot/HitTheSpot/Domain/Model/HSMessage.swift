//
//  HSGroupActivityMessage.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import NearbyInteraction
import CoreLocation

enum HSMessage {
    case profile(_ profile: HSUserProfile)
    case location(_ location: HSLocation)
}

