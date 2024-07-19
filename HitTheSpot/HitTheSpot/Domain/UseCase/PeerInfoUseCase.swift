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
        case didNIObjectRemoved(object: NINearbyObject)
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
    private let niManager: HSNearbyInteractManager
    private(set) var state: State = .init()
    
    init(
        activityManager: HSGroupActivityManager,
        niManager: HSNearbyInteractManager
    ) {
        self.activityManager = activityManager
        self.niManager = niManager
        self.activityManager.messageDelegate = self
        self.niManager.delegate = self
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .didMessageReceived(let message):
            didMessageReceivedEffect(message: message)
        case .didNIObjectUpdated(let object):
            state.nearbyObject = object
        case .didNIObjectRemoved(let object):
            didEffect(of: object) { state.nearbyObject = nil }
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
        case .token(let data):
            state.token = decode(data: data)
        }
    }
    
    private func didEffect(of object: NINearbyObject, effect: () -> Void) {
        if state.nearbyObject?.discoveryToken == object.discoveryToken {
            effect()
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

extension PeerInfoUseCase: HSNearbyInteractionDelegate {
    func didNIObjectUpdated(object: NINearbyObject) {
        effect(.didNIObjectUpdated(object: object))
    }
    
    func didNIObjectRemoved(object: NINearbyObject) {
        effect(.didNIObjectRemoved(object: object))
    }
    
    func didUpdateConvergence(convergence: NIAlgorithmConvergence, object: NINearbyObject) {
        effect(.didConvergenceUpdated(convergence: convergence, object: object))
    }
}