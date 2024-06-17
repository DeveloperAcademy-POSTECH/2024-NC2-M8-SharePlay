//
//  NISessionManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI
import NearbyInteraction
import MultipeerConnectivity
import ARKit

@Observable
class NISessionManager: NSObject {
    @ObservationIgnored private let niStatus: NIStatus
    @ObservationIgnored private let niSessionQueue = DispatchQueue(
        label: QueueLabel.niSessionQueue,
        qos: .userInitiated
    )
    
    @ObservationIgnored private var niSession: NISession?
    @ObservationIgnored private var mpcSession: MPCSession?
    @ObservationIgnored private var arSession: ARSession?
    
    @ObservationIgnored private var peerDiscoveryToken: NIDiscoveryToken?
    
    init(niStatus: NIStatus) {
        self.niStatus = niStatus
        super.init()
        // TODO: - 뷰 진입 시 Manager를 선언하는 경우 아닐 경우 수정
        startNISession()
    }
}

extension NISessionManager {
    /// NISession를 위한 ARSession 세팅 함수
    ///
    /// - Parameter arSession:
    /// sessionShouldAttemptRelocalization(_:) 메서드에서 false를 리턴하는 ARSession
    ///
    func setARSession(_ arSession: ARSession) {
        // Set the ARSession to the interaction session before
        // running the interaction session so that the framework doesn't
        // create its own AR session.
        niSession?.setARSession(arSession)
        self.arSession = arSession
        // Monitor ARKit session events.
        arSession.delegate = self
    }
}

extension NISessionManager {
    func startup() {
        startNISession()
        startMPCSession()
    }
    
    func startNISession() {
        // Create the interaction session.
        niSession = NISession()
        niSession?.delegateQueue = niSessionQueue
        
        // Set a delegate.
        niSession?.delegate = self
    }
    
    func startMPCSession() {
        if mpcSession == nil {
            // The app advertises `DiscoveryInfo` within Multipeer Connectivity framework's
            // Bonjour TXT records that identify the device for browsers to see.
            // Here, the app uses `["identity": discoveryInfoIdentity]` to advertise to peers.
            // `LocalID` is the displayName of `MCPeerID` that's sent to peers.

            // Prevent Simulator from finding devices.
            #if targetEnvironment(simulator)
            let serviceIdentity = niStatus == .extended
            ? Constant.serviceIdentityForSimulatorEDM
            : Constant.serviceIdentityForSimulator
            #else
            let serviceIdentity = Constant.serviceIdentity
            #endif
            
            let localName = UIDevice.current.name
            
            mpcSession = MPCSession(
                localID: localName,
                service: Constant.service,
                serviceIdentity: serviceIdentity,
                maxPeers: 1 // TODO: - max Peer 전환 여부 체크
            )
            
            mpcSession?.peerConnectedHandler = connectedToPeer
            mpcSession?.peerDataHandler = dataReceivedHandler
            mpcSession?.peerDisconnectedHandler = disconnectedFromPeer
        }
        
        mpcSession?.invalidate()
        mpcSession?.start()
    }
    
    func endMPCSession() {
        mpcSession?.invalidate()
        mpcSession = nil
    }
}

extension NISessionManager {
    private func connectedToPeer(peer: MCPeerID) {}
    private func disconnectedFromPeer(peer: MCPeerID) {}
    private func dataReceivedHandler(data: Data, peer: MCPeerID) {}
}

extension NISessionManager: NISessionDelegate {
    // MARK: - 세션의 피어 모니터링
    
    /// NearBy 객체의 Session이 업데이트될 때 호출
    /// - Parameters:
    ///   - session: 업데이트 된 객체의 세션
    ///   - nearbyObjects: 업데이트된 NearBy 객체의 리스트
    func session(
        _ session: NISession,
        didUpdate nearbyObjects: [NINearbyObject]
    ) {
        // Ensure there's a current peer token.
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        
        // Find the right peer from session update.
        guard let peerObj = nearbyObjects.first (where: { $0.discoveryToken == peerToken }) else {
            return
        }
        
        // MARK: - 피어의 거리 Meter 단위
        // Retrieve the peer's distance, in meters.
        if let distance = peerObj.distance {
            // Compute peer object's distance.
        }
        
        // MARK: - 피어의 수평 각도 Radian 단위
        // Retrieve the peer's horizontal angle, in radians.
        if let horizontalAngle = peerObj.horizontalAngle {
            // Compute peer object's angle.
        }
        
        // MARK: - 피어의 방향 simd_Float3 단위
        // Retrieve the peer's direction, in `simd_float3`.
        if let direction = peerObj.direction {
            // Compute peer object's direction.
        }
    }
    
    /// 1개 이상의 NearBy 객체가 제거될 때 호출
    /// - Parameters:
    ///   - session: 추적으로부터 제거된 객체의 세션
    ///   - nearbyObjects: 제거된 NearBy 객체
    ///   - reason: 제거된 이유
    func session(
        _ session: NISession,
        didRemove nearbyObjects: [NINearbyObject],
        reason: NINearbyObject.RemovalReason
    ) {
        // Only retry if the peer timed out.
        guard reason == .timeout else { return }
        
        // The session runs with one accessory.
        guard let peer = nearbyObjects.first else { return }
        
        
//        if shouldResume(peer) {
//            // Restart the session.
//            if let config = session.configuration {
//                session.run(config)
//            }
//        }
    }
    
    // MARK: - 세션의 중단 관리
    
    /// 일시 중단된 세션을 알려주는 함수
    /// 일단 백그라운드로 전환되면 세션을 일시 중지함.
    /// - Parameter session: 일시 중단한 세션
    func sessionWasSuspended(_ session: NISession) {}
    
    /// 세션의 일시 중단이 종료되었음을 알려주는 함수
    /// - Parameter session: 일시 중단한 세션
    func sessionSuspensionEnded(_ session: NISession) {}
    
    
    // MARK: - 세션의 오류 처리
    
    /// 무효화된 세션을 알려주는 함수
    /// - Parameters:
    ///   - session: 무효화된 세션
    ///   - error: 무효화된 에러 타입
    func session(
        _ session: NISession,
        didInvalidateWith error: Error
    ) {
        
    }
    
    
    // MARK: - Coaching The User
    /// Camera Assistance 프레임워크를 이용하기 위한 권장사항을 알려주는 함수?
    /// - Parameters:
    ///   - session: Camera Assistance를 활용하는 세션
    ///   - convergence: Camera Assistance 프레임워크의 상태 및 사용자 권장 사항
    ///   - object: 피어 장치 또는 타사 액세서리
    func session(
        _ session: NISession,
        didUpdateAlgorithmConvergence convergence: NIAlgorithmConvergence,
        for object: NINearbyObject?
    ) {
        
    }
}

extension NISessionManager: ARSessionDelegate {
    /// Returns `false` as required by the `NISession.setARSession(_:)` documentation.
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return false
    }
}


