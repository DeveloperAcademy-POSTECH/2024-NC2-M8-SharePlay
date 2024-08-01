//
//  GroupActivityManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/19/24.
//

import Foundation
import GroupActivities
import Combine

@Observable
final class GroupActivityManager {
    var locationMessages: [ShareLocationMessage] = []
    var statusDescription: String = ""
    
    @ObservationIgnored private var session: GroupSession<ShareLocationActivity>?
    @ObservationIgnored private var messenger: GroupSessionMessenger?
    @ObservationIgnored private let groupStateObserver = GroupStateObserver()
    
    @ObservationIgnored var sharePlayJoinedHandler: (() -> Void)?
    @ObservationIgnored var sharePlayInvalidateHandler: (() -> Void)?
    
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    init(
        sharePlayJoinedHandler: (() -> Void)? = nil,
        sharePlayInvalidateHandler: (() -> Void)? = nil
    ) {
        Task.detached {
            for await session in ShareLocationActivity.sessions() {
                self.log("새로운 활동 세션 감지됨")
                self.session = session
                self.sessionJoined(session)
            }
        }
    }
}

// MARK: - Session 관리 메서드
extension GroupActivityManager {
    private func sessionJoined(_ session: GroupSession<ShareLocationActivity>) {
        if session.state != .joined {
            session.join() // 호출 되야 세션이 시작. 일단 UI 먼저 그리고, 호출하기를 추천
        }
        
        messenger = GroupSessionMessenger(session: session)
        listenToLocations()
        monitorSessionState()
    }
    
    private func monitorSessionState() {
        session?.$state
            .sink { state in
                switch state {
                case .invalidated: 
                    // MARK: - Perform any cleanup here
                    self.log("SharePlay stop")
                    self.sharePlayInvalidateHandler?()
                    
                case .joined: 
                    // MARK: - Handle a re-join to the same session
                    self.log("SharePlay Join")
                    self.sharePlayJoinedHandler?()
                    self.session.map(self.sessionJoined)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Manager 동작 관련 메서드
extension GroupActivityManager {
    public func askStatusForSharePlay() async -> StatusForSharePlay {
        guard groupStateObserver.isEligibleForGroupSession else {
            log("SharePlay 연결 필요")
            return .needToAsk
        }
        
        // MARK: - 이미 FaceTime / SharePlay가 연결된 상태
        let activity = ShareLocationActivity()
        log("그룹 활동 시작 / 대치 여부 Alert")
        let result = await activity.prepareForActivation()
        
        switch result {
        // MARK: - 새 그룹 활동 시작 / 대치
        case .activationPreferred:
            _ = try? await activity.activate()
            log("새 그룹 활동 시작 / 대치")
            
            return .preferred
        // MARK: - 새 그룹 활동으로 비활성화 / 전환 취소
        case .activationDisabled, .cancelled:
            log("SharePlay Join")
            
            return .local
        @unknown default:
            return .needToAsk
        }
    }
    
    public func stop() {
        guard let session else { return }
        
        switch session.state {
        case .invalidated:
            break
        default:
            reset()
            session.leave()
        }
    }
    
    func reset() {
        locationMessages = []
    }
}

// MARK: - 데이터 전송 관련 메서드
extension GroupActivityManager {
    public func send(_ message: ShareLocationMessage) async throws {
        do {
            try await messenger?.send(message) // codable한 객체를 send 내부에 보낼 수 있다.
        } catch {
            print(#fileID, #function, #line, error)
        }
    }
    
    private func listenToLocations() {
        guard let messenger else { return }
        
        Task.detached {
            for await message in messenger.messages(of: ShareLocationMessage.self) {
                self.locationMessages.append(message.0)
                print("Received locations: \(message.0)")
            }
        }
    }
}

extension GroupActivityManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
        statusDescription = message
    }
}
