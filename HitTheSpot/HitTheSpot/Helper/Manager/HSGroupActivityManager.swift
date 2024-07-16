//
//  HSGroupActivityManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/13/24.
//

import Foundation
import GroupActivities
import Combine

class HSGroupActivityManager {
    typealias SessionState = GroupSession<HSShareLocationActivity>.State
    
    private let groupStateObserver = GroupStateObserver()
    private var activity: HSShareLocationActivity
    private var session: GroupSession<HSShareLocationActivity>?
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
extension HSGroupActivityManager {
    public func requestStartGroupActivity() async -> Bool {
        let result = await activity.prepareForActivation()
        
        switch result {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
                log("새로운 Group Activity 활성화")
            } catch {
                return false // (Error) .activationPreferred
            }
        default:
            return false // (Success) .activationDisabled, .canceled
        }
        
        return true // (Success) .activationPreferred
    }
    
    public func leaveGroupActivity() {
        guard let session else { return }
        
        switch session.state {
        case .invalidated:
            break
        default:
            session.leave()
        }
    }
}

// MARK: - Monitoring New Activity
extension HSGroupActivityManager {
    private func monitorNewGroupActivity() {
        Task.detached { [weak self] in
            for await session in HSShareLocationActivity.sessions() {
                self?.log("새로운 활동 세션 감지됨")
                self?.session = session
                self?.messenger = GroupSessionMessenger(session: session)
                self?.join(session)
                self?.monitorSessionState()
                self?.monitorMessage()
            }
        }
    }
    
    private func join(_ session: GroupSession<HSShareLocationActivity>) {
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
                    self.sessionDelegate?.didJoined(session)
                    
                case .waiting:
                    self.log("Waiting to GroupSession")
                    self.sessionDelegate?.waiting(session)
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Messaging
extension HSGroupActivityManager {
    public func send(_ message: HSPeerInfoMessage) async throws {
        do {
            try await messenger?.send(message)
        } catch {
            log(error.localizedDescription)
        }
    }
    
    private func monitorMessage() {
        guard let messenger else { return }
        
        Task.detached {
            for await message in messenger.messages(of: HSPeerInfoMessage.self) {
                self.messageDelegate?.receive(message.0)
            }
        }
    }
}

// MARK: - Log
extension HSGroupActivityManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}
