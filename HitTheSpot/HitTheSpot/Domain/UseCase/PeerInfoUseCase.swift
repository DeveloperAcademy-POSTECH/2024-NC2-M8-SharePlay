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
        case didNIObjectUpdated(object: NINearbyObject)
        case didConvergenceUpdated(
            convergence: NIAlgorithmConvergence,
            object: NINearbyObject
        )
    }
    
    struct State {
        var profile: HSUserProfile? = nil
        var location: HSLocation? = nil
        var token: NIDiscoveryToken? = nil
        var nearbyObject: NINearbyObject? = nil
        var convergence: NIAlgorithmConvergence? = nil
    }
    
    private let activityManager: HSGroupActivityManager
    private let niManager: NISessionManager
    private(set) var state: State = .init()
    
    init(
        activityManager: HSGroupActivityManager,
        niManager: NISessionManager
    ) {
        self.activityManager = activityManager
        self.niManager = niManager
        self.activityManager.messageDelegate = self
        self.niManager.niObjectDelegate = self
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .didMessageReceived(let message):
            didMessageReceivedEffect(message: message)
        case .didNIObjectUpdated(let object):
            state.nearbyObject = object
        case .didConvergenceUpdated(let convergence, let object):
            didEffect(of: object) { state.convergence = convergence }
        }
    }
    
    private func didMessageReceivedEffect(message: HSPeerInfoMessage) {
        switch message {
        case .profile(let profile):
            state.profile = profile
        case .location(let location):
            state.location = location
        }
    }
    
    private func didEffect(of object: NINearbyObject, effect: () -> Void) {
        if state.nearbyObject?.discoveryToken == object.discoveryToken {
            effect()
        }
    }
}

extension PeerInfoUseCase: HSMessagingDelegate {
    func receive(_ message: HSPeerInfoMessage) {
        effect(.didMessageReceived(message: message))
    }
}

extension PeerInfoUseCase: HSNIObjectDelegate {
    func didNIObjectUpdated(object: NINearbyObject) {
        effect(.didNIObjectUpdated(object: object))
    }
    
    func didUpdateConvergence(convergence: NIAlgorithmConvergence, object: NINearbyObject) {
        effect(.didConvergenceUpdated(convergence: convergence, object: object))
    }
}
