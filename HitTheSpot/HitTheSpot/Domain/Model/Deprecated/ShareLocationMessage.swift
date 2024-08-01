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
    let location: HSLocation
}
