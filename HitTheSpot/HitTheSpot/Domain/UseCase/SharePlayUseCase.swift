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
        case bindIsSheetPresented
        case sessionJoined
        case sessionWaiting
        case sessionInvalidated(reason: Error)
    }
    
    struct State {
        var sessionState: SessionState = .invalidated(reason: NSError())
        var isActivated: Bool = false
        var isSheetPresented: Bool = false
    }
    
    private let manager: HSGroupActivityManager
    private(set) var state: State = .init()
    
    init(manager: HSGroupActivityManager) {
        self.manager = manager
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
                    state.isSheetPresented = true
                }
            }
        case .bindIsSheetPresented:
            state.isSheetPresented.toggle()
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
