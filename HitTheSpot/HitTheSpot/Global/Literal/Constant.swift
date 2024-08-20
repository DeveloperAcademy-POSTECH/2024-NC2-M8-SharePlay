//
//  Constant.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import Foundation

enum Constant {
    static let service = "HitTheSpot"
    static let serviceIdentity = "com.myulaGilah.HitTheSpot"
    static let serviceIdentityForSimulator = "com.myulaGilah.HitTheSpot.simulator"
    static let serviceIdentityForSimulatorEDM = "com.myulaGilah.HitTheSpot.simulator-edm"
    
    static let activityIdentifier = "com.myulaGilah.HitTheSpot.ShareLocationActivity"
}

enum QueueLabel {
    static let mpcSessionSerialQueue = "HitTheSpot.MPCSession.MPCQueue"
    static let niSessionQueue = "HitTheSpot.NISessionManager.NISessionQueue"
}

enum ThreshHold {
    static let maxDistance: Float = 50.0
    static let nearByDistance: Float = 0.3
    static let minSamples: Int = 8
}
