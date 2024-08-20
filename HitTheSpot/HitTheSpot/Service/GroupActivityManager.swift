//
//  GroupActivityManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/13/24.
//

import Foundation
import GroupActivities
import Combine

class GroupActivityManager {
    typealias SessionState = GroupSession<HitTheSpotActivity>.State
    
    private let groupStateObserver = GroupStateObserver()
    private(set) var activity: HitTheSpotActivity
    private var session: GroupSession<HitTheSpotActivity>?
    private var messenger: GroupSessionMessenger?
    
    private var cancellables = Set<AnyCancellable>()
    
    var isGroupActivityAvailable: Bool { groupStateObserver.isEligibleForGroupSession }
    var sessionState: SessionState { session?.state ?? .invalidated(reason: NSError()) }
    
    weak var sessionDelegate: HSGroupSessionDelegate?
    weak var messageDelegate: HSMessagingDelegate?
    
    init() {
        self.activity = .init()
        self.monitorNewGroupActivity()
    }
}

// MARK: - start/leave Activity
extension GroupActivityManager {
    public func requestStartGroupActivity() async throws {
        let result = await activity.prepareForActivation()
        
        switch result {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
                log("새로운 Group Activity 활성화")
            } catch {
                // (Error) .activationPreferred
                log("Group Activity 활성화 ERROR")
            }
        default:
            return // (Success) .activationDisabled, .canceled
        }
        
        return // (Success) .activationPreferred
    }
    
    public func leaveGroupActivity() {
        guard let session else { return }
        
        switch session.state {
        case .invalidated:
            break
        default:
            session.end()
        }
    }
}

// MARK: - Monitoring New Activity
extension GroupActivityManager {
    private func monitorNewGroupActivity() {
        Task.detached { [weak self] in
            for await session in HitTheSpotActivity.sessions() {
                self?.log("새로운 활동 세션 감지됨")
                self?.session = session
                self?.messenger = GroupSessionMessenger(session: session)
                self?.join(session)
                self?.monitorSessionState()
                self?.monitorActiveParticipants()
                self?.monitorMessage()
            }
        }
    }
    
    private func join(_ session: GroupSession<HitTheSpotActivity>) {
        if session.state != .joined {
            session.join()
        }
    }
    
    private func monitorSessionState() {
        guard let session else { return }
        
        session.$state
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .invalidated(let error):
                    self.log("stop GroupSession")
                    self.session = nil
                    self.messenger = nil
                    self.sessionDelegate?.didInvalidated(session, reason: error)
                    
                case .joined:
                    self.log("Join to GroupSession")
                    self.session.map(self.join(_:))
                    self.sessionDelegate?.didLocalJoined(session)
                    
                case .waiting:
                    self.log("Waiting to GroupSession")
                    self.sessionDelegate?.didLocalWaiting(session)
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func monitorActiveParticipants() {
        guard let session else { return }
        
        session
            .$activeParticipants
            .sink { [weak self] in
                guard let self else { return }
                self.sessionDelegate?.didParticipantsUpdated(
                    session,
                    local: session.localParticipant,
                    activeParticipants: $0
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - Messaging
extension GroupActivityManager {
    public func send(_ message: HSMessage) async throws {
        do {
            switch message {
            case .profile(let profile):
                try await messenger?.send(profile)
            case .location(let location):
                try await messenger?.send(location)
            }
            
        } catch {
            log(error.localizedDescription)
        }
    }
    
    private func monitorMessage() {
        guard let messenger else { return }
        
        Task.detached {
            for await message in messenger.messages(of: HSUserProfile.self) {
                self.messageDelegate?.receive(.profile(message.0))
            }
        }
        
        Task.detached {
            for await message in messenger.messages(of: HSLocation.self) {
                self.messageDelegate?.receive(.location(message.0))
            }
        }
    }
}

// MARK: - Log
extension GroupActivityManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}
