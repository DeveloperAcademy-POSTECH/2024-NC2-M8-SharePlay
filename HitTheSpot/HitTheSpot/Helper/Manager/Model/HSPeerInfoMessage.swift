//
//  HSGroupActivityMessage.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import NearbyInteraction
import CoreLocation

enum HSPeerInfoMessage: Codable {
    case profile(profile: HSUserProfile)
    case location(location: HSLocation)
    case token(token: Data)
}
