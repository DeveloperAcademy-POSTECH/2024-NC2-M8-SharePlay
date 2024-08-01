//
//  HSGroupActivityMessage.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import NearbyInteraction
import CoreLocation

enum HSPeerInfoMessage {
    case profile(_ profile: HSUserProfile)
    case location(_ location: HSLocation)
    case token(_ token: Data)
}

