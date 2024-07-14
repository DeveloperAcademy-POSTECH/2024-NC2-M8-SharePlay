//
//  HSGroupSessionDelegate.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import GroupActivities

protocol HSGroupSessionDelegate: AnyObject {
    // MARK: - Monitoring Session
    func didInvalidated(_ session: GroupSession<HSShareLocationActivity>)
    func didJoined(_ session: GroupSession<HSShareLocationActivity>)
    func waiting(_ session: GroupSession<HSShareLocationActivity>)
    
    // MARK: - Messaging
    func receive(_ message: HSShareLocationMessage)
}
