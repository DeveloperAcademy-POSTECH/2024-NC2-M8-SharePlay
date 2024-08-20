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

protocol HSNIObjectDelegate: AnyObject {
    func didNIObjectUpdated(object: NINearbyObject)
    func didUpdateConvergence(
        convergence: NIAlgorithmConvergence,
        object: NINearbyObject
    )
}

class NISessionManager: NSObject {
    /// NISession의 세션 동기화 작업을 위한 Queue
    private let niSessionQueue = DispatchQueue(
        label: QueueLabel.niSessionQueue,
        qos: .userInitiated
    )
    
    /// 상대 Peer와의 측정 퀄리티 측정 객체
    private let qualityEstimator: MeasurementQualityEstimator?
    
    /// 현재 Nearby Interation Session
    private var niSession: NISession?
    
    /// 현재 Multipeer Connectivity Session
    private var mpcSession: MPCSession?
    
    /// 현재 AR Session
    private var arSession: ARSession?
    
    /// MPCSession으로 연결된 Peer의 DiscoveryToken
    private var peerDiscoveryToken: NIDiscoveryToken?
    
    /// MPCSession으로 연결된 Peer의 NISession으로 제공받은 NearbyObject(거리, 방향 정보)
    private var currentNearbyObject: NINearbyObject?
    
    /// MPCSession으로 연결된 Peer
    private var connectedPeer: MCPeerID? = nil
    
    /// MPCSession으로 연결된 Peer에게 DiscoveryToken을 전송했는 지 여부
    private var sharedTokenWithPeer = false
    
    /// Nearby Interaction에서 카메라 지원을 활성화 했을 때, 런타임에서 필요로 하는 카메라 세팅의 권장사항
    private var convergenceContext: NIAlgorithmConvergence?
    
    
    
    weak var niObjectDelegate: HSNIObjectDelegate?
    
    override init() {
        self.qualityEstimator = MeasurementQualityEstimator()
        super.init()
    }
    
    deinit {
        niSession?.invalidate()
        mpcSession?.invalidate()
    }
}

// MARK: - NISessionManager 동작 메서드
extension NISessionManager {
    func startup() {
        // TODO: - View initialize
        resetPeerData()
        startNISession()
        startMPCSession()
    }
    
    func invalidate() {
//        arSession?.pause()
        resetPeerData()
        invalidateMPCSession()
        invalidateNISession()
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
            let serviceIdentity = Constant.serviceIdentityForSimulatorEDM
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
    
    func invalidateNISession() {
        niSession?.invalidate()
        niSession = nil
    }
    
    func invalidateMPCSession() {
        mpcSession?.invalidate()
        mpcSession = nil
    }
    
    func resetPeerData() {
        sharedTokenWithPeer = false
        connectedPeer = nil
    }
    
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

// MARK: - MPCSession 관련 상호작용 메서드
extension NISessionManager {
    /// MPCSession에서 Peer와 연결되었을 때 실행할 클로저
    /// - Parameter peer: 연결된 Peer
    private func connectedToPeer(peer: MCPeerID) {
        guard let myToken = niSession?.discoveryToken else {
            fatalError("Unexpectedly failed to initialize nearby interaction session.")
        }

        guard connectedPeer == nil else {
            log("이미 연결된 Peer와 연결되어 있습니다.")
            return
        }

        // Peer에게 내 토큰 전달
        if !sharedTokenWithPeer {
            shareMyDiscoveryToken(token: myToken)
        }

        // 연결된 Peer 정보 저장
        connectedPeer = peer
    }
    
    /// MPCSession에서 Peer와 연결이 끊어졌을 때 실행할 클로저
    /// - Parameter peer: 연결이 끊어진 Peer
    private func disconnectedFromPeer(peer: MCPeerID) {
        // TODO: - 여러 Peer와 연결될 경우, 배열에서 삭제하는 로직으로 수정
        if connectedPeer == peer { resetPeerData() }
    }
    
    /// MPCSession에서 DiscoveryToken을 전송 받았을 때 실행할 클로저
    /// - Parameters:
    ///   - data: 전송받은 데이터
    ///   - peer: 전송한 Peer
    private func dataReceivedHandler(data: Data, peer: MCPeerID) {
        guard let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: NIDiscoveryToken.self,
            from: data
        ) else {
            fatalError("Unexpectedly failed to decode discovery token.")
        }
        
        peerDidShareDiscoveryToken(peer: peer, token: discoveryToken)
    }
    
    /// MPCSession에 있는 Peer들에게 내 토큰 정보를 전송하는 함수
    /// - Parameter token: 전송할 내 기기 토큰
    private func shareMyDiscoveryToken(token: NIDiscoveryToken) {
        guard let encodedData = try? NSKeyedArchiver.archivedData(
            withRootObject: token,
            requiringSecureCoding: true
        ) else {
            fatalError("Unexpectedly failed to encode discovery token.")
        }
        
        mpcSession?.sendDataToAllPeers(data: encodedData)
        sharedTokenWithPeer = true
    }
    
    /// Peer가 DiscoveryToken를 전송했을 때, dataReceivedHandler 클로저 안에서 실행하는 함수
    /// - Parameters:
    ///   - peer: DiscoveryToken을 전송한 Peer
    ///   - token: 전송한 token description
    private func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        guard connectedPeer == peer else {
            log("Received a token from an unexpected peer.")
            return
        }
        
        // 토큰 정보 저장
        peerDiscoveryToken = token
        
        niSessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let config = NINearbyPeerConfiguration(peerToken: token)
            config.isCameraAssistanceEnabled = true
            config.isExtendedDistanceMeasurementEnabled = true
            
            log("\(peer.displayName) 위치 인식 시작")
            
            // NISession 시작
            self.niSession?.run(config)
        }
    }
}

// MARK: - NISessionDelegate: Peer 모니터링 관련 메서드
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
        
        // When the session is ranging with its peer, the data connection might drop
        // after which which you don't need to keep it.
        // Tear down the MPC session after the app initially started ranging with the peer.
        // After the current ranging session stops and is invalidated, the app
        // restarts a new MPC data connection for a new peer.
        if mpcSession != nil {
            resetPeerData()
            invalidateMPCSession()
        }

        // Update and compute with updated `nearbyObject`.
        currentNearbyObject = peerObj
        niObjectDelegate?.didNIObjectUpdated(object: peerObj)
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
        startup()
    }
}

// MARK: - NISessionDelegate: 세션의 오류 처리 메서드
extension NISessionManager {
    /// 무효화된 세션을 알려주는 함수
    /// - Parameters:
    ///   - session: 무효화된 세션
    ///   - error: 무효화된 에러 타입
    func session(
        _ session: NISession,
        didInvalidateWith error: Error
    ) {
        // If the app doesn't have approval for Nearby Interaction, present
        // an option to open the Settings app where the they can update the access.
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
        
        // Recreate a valid session in other failure cases.
        startup()
    }
}

// MARK: - NISessionDelegate: 세션의 중단 관리 관련 메서드
extension NISessionManager {
    /// 일시 중단된 세션을 알려주는 함수
    /// 일단 백그라운드로 전환되면 세션을 일시 중지함.
    /// - Parameter session: 일시 중단한 세션
    func sessionWasSuspended(_ session: NISession) {}
    
    /// 세션의 일시 중단이 종료되었음을 알려주는 함수
    /// - Parameter session: 일시 중단한 세션
    func sessionSuspensionEnded(_ session: NISession) {
        // Session suspension ends. You can run the session again, or restart
        // it if the session was invalid.
        if let config = self.niSession?.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            startup()
        }
    }
}

// MARK: - NISessionDelegate: Camera Assitance 프레임워크 사용 권장사항을 알려주는 메서드
extension NISessionManager {
    /// Camera Assistance 프레임워크를 이용하기 위한 권장사항을 알려주는 함수
    ///
    /// ex) 카메라가 다양한 수평 각도에서 사용자 환경을 보아야 함
    /// ex) 카메라가 더 나은 조명 조건에서 물리적 환경을 확인해야 함
    ///
    /// - Parameters:
    ///   - session: Camera Assistance를 활용하는 세션
    ///   - convergence: Camera Assistance 프레임워크의 상태 및 사용자 권장 사항
    ///   - object: 피어 장치 또는 타사 액세서리
    func session(
        _ session: NISession,
        didUpdateAlgorithmConvergence convergence: NIAlgorithmConvergence,
        for object: NINearbyObject?
    ) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("Don't have peer token.")
        }

        guard let nearbyObject = object, nearbyObject.discoveryToken == peerToken else {
            return
        }

        // Update and compute with updated algorithm `convergence` and `nearbyObject`.
        currentNearbyObject = nearbyObject
        convergenceContext = convergence
        niObjectDelegate?.didUpdateConvergence(
            convergence: convergence,
            object: nearbyObject
        )
    }
}

// MARK: - ARSession 관련 메서드
extension NISessionManager: ARSessionDelegate {
    /// Returns `false` as required by the `NISession.setARSession(_:)` documentation.
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return false
    }
}

extension NISessionManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}
