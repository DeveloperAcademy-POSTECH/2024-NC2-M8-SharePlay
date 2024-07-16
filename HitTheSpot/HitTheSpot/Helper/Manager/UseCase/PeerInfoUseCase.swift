//
//  PeerInfoUseCase.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/16/24.
//

import SwiftUI
import CoreLocation
import NearbyInteraction

@Observable
class PeerInfoUseCase {
    enum Action {
        case didMessageReceived(message: HSPeerInfoMessage)
    }
    
    struct State {
        var profile: HSUserProfile? = nil
        var location: HSLocation? = nil
        var token: NIDiscoveryToken? = nil
        var nearbyObject: NINearbyObject? = nil
    }
    
    private let manager: HSGroupActivityManager
    private(set) var state: State = .init()
    
    init(manager: HSGroupActivityManager) {
        self.manager = manager
        self.manager.messageDelegate = self
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .didMessageReceived(let message):
            didMessageReceivedEffect(message: message)
        }
    }
    
    private func didMessageReceivedEffect(message: HSPeerInfoMessage) {
        switch message {
        case .profile(let profile):
            state.profile = profile
        case .location(let location):
            state.location = location
        case .token(let data):
            state.token = decode(data: data)
        }
    }
    
    private func decode<T: NSObject & NSSecureCoding>(data: Data) -> T? {
        guard let decodedObject = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: T.self,
            from: data
        ) else {
            return nil
        }
        return decodedObject
    }
}

extension PeerInfoUseCase: HSMessagingDelegate {
    func receive(_ message: HSPeerInfoMessage) {
        effect(.didMessageReceived(message: message))
    }
}
