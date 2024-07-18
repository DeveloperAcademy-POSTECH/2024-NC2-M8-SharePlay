//
//  HSNIManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/17/24.
//

import Foundation
import NearbyInteraction
import ARKit

protocol HSNearbyInteractionDelegate: AnyObject {
    func didNIObjectUpdated(object: NINearbyObject)
    func didNIObjectRemoved(object: NINearbyObject)
    func didUpdateConvergence(
        convergence: NIAlgorithmConvergence,
        object: NINearbyObject
    )
}

class HSNearbyInteractManager: NSObject {
    private let niSessionQueue = DispatchQueue(
        label: QueueLabel.niSessionQueue,
        qos: .userInitiated
    )
    
    private var niSession: NISession?
    private var arSession: ARSession?
    
    private var peerToken: NIDiscoveryToken?
    
    weak var delegate: HSNearbyInteractionDelegate?
}

extension HSNearbyInteractManager {
    private func startup() {
        resetPeerData()
        startNISession()
    }
    
    private func invalidate() {
        arSession?.pause()
        niSession?.invalidate()
        niSession = nil
    }
    
    private func startNISession() {
        niSession = NISession()
        niSession?.delegateQueue = niSessionQueue
        niSession?.delegate = self
    }
    
    private func resetPeerData() {
        peerToken = nil
    }
}

extension HSNearbyInteractManager {
    private func peerDidShareDiscoveryToken(token: NIDiscoveryToken) {
        peerToken = token
        
        niSessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let config = NINearbyPeerConfiguration(peerToken: token)
            config.isCameraAssistanceEnabled = true
            config.isExtendedDistanceMeasurementEnabled = true
            
            log("NISession 시작")
            
            self.niSession?.run(config)
        }
    }
}

extension HSNearbyInteractManager: NISessionDelegate {
    func session(
        _ session: NISession,
        didUpdate nearbyObjects: [NINearbyObject]
    ) {
        guard let peerToken = peerToken else {
            fatalError("don't have peer token")
        }
        
        guard let peerObj = nearbyObjects.first(where: {
            $0.discoveryToken == peerToken
        }) else { return }
        
        delegate?.didNIObjectUpdated(object: peerObj)
    }
    
    func session(
        _ session: NISession,
        didRemove nearbyObjects: [NINearbyObject],
        reason: NINearbyObject.RemovalReason
    ) {
        startup()
    }
    
    func session(
        _ session: NISession,
        didInvalidateWith error: Error
    ) {
        if #available(iOS 17.0, watchOS 10.0, *) {
            switch error {
            case NIError.userDidNotAllow,
                NIError.invalidARConfiguration,
                NIError.incompatiblePeerDevice,
                NIError.activeSessionsLimitExceeded,
                NIError.activeExtendedDistanceSessionsLimitExceeded:
                return
            default:
                break
            }
        } else {
            switch error {
            case NIError.userDidNotAllow,
                NIError.invalidARConfiguration,
                NIError.activeSessionsLimitExceeded:
                return
            default:
                break
            }
        }
    
        startup()
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        if let config = self.niSession?.configuration {
            session.run(config)
        } else {
            startup()
        }
    }
}

// MARK: - ARSession 메서드
extension HSNearbyInteractManager: ARSessionDelegate {
    func setARSession(_ arSession: ARSession) {
        niSession?.setARSession(arSession)
        self.arSession = arSession
        arSession.delegate = self
    }
    
    func session(
        _ session: NISession,
        didUpdateAlgorithmConvergence convergence: NIAlgorithmConvergence,
        for object: NINearbyObject?
    ) {
        guard let peerToken = peerToken else {
            fatalError("Don't have peer token.")
        }

        guard let nearbyObject = object,
              nearbyObject.discoveryToken == peerToken
        else {
            return
        }

        delegate?.didUpdateConvergence(convergence: convergence, object: nearbyObject)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return false
    }
}

// MARK: - Log
extension HSNearbyInteractManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}
