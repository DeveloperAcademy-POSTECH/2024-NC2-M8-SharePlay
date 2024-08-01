//
//  StatusForSharePlay.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/19/24.
//

import Foundation

enum StatusForSharePlay {
    case preferred
    case local
    case needToAsk
    
    var isNeedToAsk: Bool {
        self == .needToAsk
    }
}
