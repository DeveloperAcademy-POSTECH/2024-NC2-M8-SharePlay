//
//  HSGroupSessionDelegate.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import GroupActivities

// MARK: - Monitoring Session
protocol HSGroupSessionDelegate: AnyObject {
    typealias Session = GroupSession<HSShareLocationActivity>
    
    func didInvalidated(_ session: Session, reason: Error)
    func didLocalJoined(_ session: Session)
    func didLocalWaiting(_ session: Session)
    
    func didParticipantsUpdated(
        _ session: Session,
        local: Participant,
        activeParticipants: Set<Participant>
    )
}

