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
        case didNearby
        case isFinding
        case didMessageReceived(message: HSMessage)
        case didNIObjectUpdated(object: NINearbyObject)
        case didConvergenceUpdated(
            convergence: NIAlgorithmConvergence,
            object: NINearbyObject
        )
    }
    
    struct State {
        var profile: HSUserProfile? = nil
        var location: HSLocation? = nil
        var nearbyObject: NINearbyObject? = nil
        var convergence: NIAlgorithmConvergence? = nil
        var isNearby: Bool = false
    }
    
    private let activityManager: GroupActivityManager
    private let niManager: NISessionManager
    private(set) var state: State = .init()
    
    init(
        activityManager: GroupActivityManager,
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
        case .didNearby:
            VibrationManager.shared?.playHaptic(haptic: .sample)
            state.isNearby = true
        case .isFinding:
            VibrationManager.shared?.stopHaptic()
            state.isNearby = false
        }
    }
    
    private func didMessageReceivedEffect(message: HSMessage) {
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
    func receive(_ message: HSMessage) {
        effect(.didMessageReceived(message: message))
    }
}

extension PeerInfoUseCase: HSNIObjectDelegate {
    func didNIObjectUpdated(object: NINearbyObject) {
        effect(.didNIObjectUpdated(object: object))
        
        guard let distance = object.distance else { return }
    
        switch distance {
        case 0..<ThreshHold.nearByDistance:
            if !state.isNearby { effect(.didNearby) }
        default:
            if state.isNearby { effect(.isFinding) }
        }
    }
    
    func didUpdateConvergence(convergence: NIAlgorithmConvergence, object: NINearbyObject) {
        effect(.didConvergenceUpdated(convergence: convergence, object: object))
    }
}
