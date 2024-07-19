//
//  HSUserProfile.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/16/24.
//

import UIKit

struct HSUserProfile: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let image: Data?
}
