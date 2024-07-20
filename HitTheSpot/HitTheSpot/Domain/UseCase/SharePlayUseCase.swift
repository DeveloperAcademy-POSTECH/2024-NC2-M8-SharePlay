//
//  SharePlayUseCase.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation
import GroupActivities

@Observable
class SharePlayUseCase {
    typealias Activity = HSShareLocationActivity
    typealias SessionState = GroupSession<Activity>.State
    
    enum Action {
        case startSharePlayBtnTap
        case didSheetPresented(_ isPresented: Bool)
        case didParticipantCountUpdated(_ count: Int)
        case sessionJoined
        case sessionWaiting
        case sessionInvalidated(reason: Error)
    }
    
    struct State {
        var activity: HSShareLocationActivity
        var participantCount: Int = 0
        var sessionState: SessionState = .invalidated(reason: NSError())
        var isActivated: Bool = false
        var isSharePlaySheetPresented: Bool = false
    }
    
    private let manager: HSGroupActivityManager
    private(set) var state: State
    
    init(manager: HSGroupActivityManager) {
        self.manager = manager
        self.state = .init(activity: manager.activity)
        self.manager.sessionDelegate = self
    }
}

extension SharePlayUseCase {
    public func effect(_ action: Action) {
        switch action {
        case .startSharePlayBtnTap:
            Task {
                if manager.isGroupActivityAvailable {
                    state.isActivated = await manager.requestStartGroupActivity()
                } else {
                    state.isSharePlaySheetPresented = true
                }
            }
        case .didSheetPresented(let isPresented):
            state.isSharePlaySheetPresented = isPresented
        case .didParticipantCountUpdated(let count):
            state.participantCount = count
        case .sessionJoined:
            state.sessionState = .joined
        case .sessionWaiting:
            state.sessionState = .waiting
        case .sessionInvalidated(let reason):
            state.sessionState = .invalidated(reason: reason)
        }
    }
}

extension SharePlayUseCase: HSGroupSessionDelegate {
    func didPeerCountUpdated(_ session: Session, count: Int) {
        effect(.didParticipantCountUpdated(count))
    }
    
    func didInvalidated(_ session: GroupSession<Activity>, reason: Error) {
        effect(.sessionInvalidated(reason: reason))
    }
    
    func didJoined(_ session: GroupSession<Activity>) {
        effect(.sessionJoined)
    }
    
    func waiting(_ session: GroupSession<Activity>) {
        effect(.sessionWaiting)
    }
}
