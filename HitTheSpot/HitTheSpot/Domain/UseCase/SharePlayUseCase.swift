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
    typealias Activity = HitTheSpotActivity
    
    enum SharePlayState {
        case notJoined
        case onlyLocal
        case localWithPeer
    }
    
    enum Action {
        case startSharePlayBtnTap
        case stopSharePlayBtnTap
        case didSheetPresented(_ isPresented: Bool)
        case didSharePlayStateUpdated(_ sharePlayState: SharePlayState, _ count: Int)
    }
    
    struct State {
        var activity: HitTheSpotActivity
        var isActivated: Bool = false
        var isSharePlaySheetPresented: Bool = false
        var participantCount: Int = 0
        var sharePlayState: SharePlayState = .notJoined
    }
    
    private let manager: GroupActivityManager
    private(set) var state: State
    
    init(manager: GroupActivityManager) {
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
        case .stopSharePlayBtnTap:
            manager.leaveGroupActivity() 
        case .didSheetPresented(let isPresented):
            state.isSharePlaySheetPresented = isPresented
        case .didSharePlayStateUpdated(let sharePlayState, let count):
            state.sharePlayState = sharePlayState
            state.participantCount = count
        }
    }
}

extension SharePlayUseCase: HSGroupSessionDelegate {
    func didInvalidated(_ session: Session, reason: any Error) {
        effect(.didSharePlayStateUpdated(.notJoined, 0))
    }
    
    func didLocalJoined(_ session: Session) {}
    func didLocalWaiting(_ session: Session) {}
    
    func didParticipantsUpdated(
        _ session: Session,
        local: Participant,
        activeParticipants: Set<Participant>
    ) {
        let count = activeParticipants.count
        let isLocalJoined = activeParticipants.contains(local)
        
        switch (isLocalJoined, count) {
        case (true, 1):
            effect(.didSharePlayStateUpdated(.onlyLocal, 1))
        case (true, _):
            effect(.didSharePlayStateUpdated(.localWithPeer, count))
        default:
            effect(.didSharePlayStateUpdated(.notJoined, count))
        }
    }
}
