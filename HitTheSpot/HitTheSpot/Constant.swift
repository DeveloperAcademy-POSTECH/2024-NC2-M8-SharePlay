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
}

enum QueueLabel {
    static let mpcSessionSerialQueue = "HitTheSpot.MPCSession.MPCQueue"
    static let niSessionQueue = "HitTheSpot.NISessionManager.NISessionQueue"
}
