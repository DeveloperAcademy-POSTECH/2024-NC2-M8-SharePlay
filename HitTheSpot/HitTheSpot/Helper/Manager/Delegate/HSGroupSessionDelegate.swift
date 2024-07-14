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
    func didInvalidated(_ session: GroupSession<some GroupActivity>)
    func didJoined(_ session: GroupSession<some GroupActivity>)
    func waiting(_ session: GroupSession<some GroupActivity>)
    
    // MARK: - Messaging
    func receive(_ message: Codable)
}
