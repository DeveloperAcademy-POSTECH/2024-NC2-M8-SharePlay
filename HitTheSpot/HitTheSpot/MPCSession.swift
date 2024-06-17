//
//  MPCSession.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import Foundation
import MultipeerConnectivity

struct MPCSessionConstants {
    static let kKeyIdentity: String = "identity"
}

class MPCSession: NSObject {
    // MARK: - Action 클로저
    
    /// Peer에게 데이터를 전송 받았을 때 실행되는 클로저
    var peerDataHandler: ((Data, MCPeerID) -> Void)?
    
    /// Peer가 연결되면 실행되는 클로저
    var peerConnectedHandler: ((MCPeerID) -> Void)?
    
    /// Peer가 연결이 끊어지면 실행되는 클로저
    var peerDisconnectedHandler: ((MCPeerID) -> Void)?
    
    // MARK: - Immutable
    
    /// 모든 Peer 간의 통신을 활성화하고 관리하는 세션
    private let mcSession: MCSession
    
    /// 앱이 지정된 유형의 세션에 참여할 의향이 있음을 알리는 역할
    private let mcAdvertiser: MCNearbyServiceAdvertiser
    
    /// 특정 유형의 세션을 지원하는 앱이 있는 주변 장치를 검색하는 역할
    private let mcBrowser: MCNearbyServiceBrowser
    
    /// 자신의 Peer ID
    private let localPeerID: MCPeerID
    
    /// 서비스 정보 - MCNearbyServiceAdvertiser 및 MCNearbyServiceBrowser에서 사용
    private let serviceString: String
    
    /// 탐색 정보 - MCNearbyServiceAdvertiser에서 사용
    private let discoveryInfoIdentity: String
    
    /// 최대 연결할 수 있는 Peer의 수
    private let maxNumPeers: Int
    
    // MARK: - Mutable
    
    /// 현재 연결된 Peer 배열
    private var currentConnectedPeers: [MCPeerID]
    
    /// 앱을 사용하는 동안 Connetion, Disconnections, Invitation의 Send, Accept를 동기화하기 위한 Queue입니다.
    private var mpcSessionSerialQueue: DispatchQueue
    
    init(
        localID: String,
        service: String,
        serviceIdentity: String,
        maxPeers: Int
    ) {
        // MARK: - MPC 기본 정보 할당
        self.localPeerID = MCPeerID(displayName: localID)
        self.serviceString = service
        self.discoveryInfoIdentity = serviceIdentity
        
        // MARK: - MCSession 생성
        self.mcSession = MCSession(
            peer: localPeerID,
            securityIdentity: nil, // TODO: - 암호화 여부 체크
            encryptionPreference: .required
        )
        
        // MARK: - MCNearbyServiceAdvertiser 생성
        self.mcAdvertiser = MCNearbyServiceAdvertiser(
            peer: localPeerID,
            discoveryInfo: [
                MPCSessionConstants.kKeyIdentity: discoveryInfoIdentity
            ],
            serviceType: serviceString
        )
        
        // MARK: - MCNearbyServiceBrowser 생성
        self.mcBrowser = MCNearbyServiceBrowser(
            peer: localPeerID,
            serviceType: serviceString
        )
        
        // MARK: - 옵션 세팅
        self.maxNumPeers = maxPeers
        self.currentConnectedPeers = [MCPeerID]()
        self.mpcSessionSerialQueue = DispatchQueue(
            label: "HitTheSpot.mpcQueue",
            qos: .default
        )
        
        super.init()
        
        mcSession.delegate = self
        mcAdvertiser.delegate = self
        mcBrowser.delegate = self
    }
}

extension MPCSession {
    public func start() {
        NSLog("Start advertising.")
        mcAdvertiser.startAdvertisingPeer()
        mcBrowser.startBrowsingForPeers()
    }
    
    public func suspend() {
        NSLog("Suspend advertising.")
        mcAdvertiser.stopAdvertisingPeer()
        mcBrowser.stopBrowsingForPeers()
    }
    
    public func invalidate() {
        NSLog("Invalidating the session and disconnecting peers.")
        suspend()
        mcSession.disconnect()
        currentConnectedPeers.removeAll()
    }
}

extension MPCSession {
    private func peerConnected(peerID: MCPeerID) {
        NSLog("Connected peer: \(peerID).")
        
        // 최대 Peer 수를 넘어가면, 주변 광고 및 탐색을 멈춤
        guard currentConnectedPeers.count < maxNumPeers else {
            self.suspend()
            return
        }
        
        // 이미 등록된 Peer라면 무시
        guard !currentConnectedPeers.contains(peerID) else {
            return
        }
        
        // Peer 정보 추가
        currentConnectedPeers.append(peerID)
        
        // Peer가 연결됐다는 클로저를 실행
        if let handler = peerConnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
    }
    
    private func peerDisconnected(peerID: MCPeerID) {
        NSLog("Disconnected peer: \(peerID).")
        
        // 연결이 끊긴 Peer가 현재 연결된 데이터에 있는 지 확인
        guard currentConnectedPeers.contains(peerID) else {
            return
        }
        
        // Peer 정보 삭제
        currentConnectedPeers.removeAll { $0 == peerID }
        
        // Peer가 연결이 끊어졌다는 클로저를 실행
        if let handler = peerDisconnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
    }
}

extension MPCSession: MCSessionDelegate {
    /// MCSession에서 Peer의 상태에 변화가 있을 때 호출되는 함수
    ///
    /// Peer의 상태에 따라 peerConnected 혹은 peerDisconnected를 호출합니다.
    /// currentConnectedPeers에 정보를 업데이트하고,
    /// 해당 상태에 따른 클로저를 실행합니다.
    ///
    /// - Parameters:
    ///   - session: Peer를 관리하는 세션
    ///   - peerID: 상태가 변경된 Peer의 ID
    ///   - state: Peer의 새 상태
    internal func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        mpcSessionSerialQueue.sync { [weak self] in
            switch state {
            case .connected:
                self?.peerConnected(peerID: peerID)
            case .notConnected:
                self?.peerDisconnected(peerID: peerID)
            case .connecting:
                break
            @unknown default:
                fatalError("Unhandled MCSessionState.")
            }
        }
    }
    
    /// Peer로 부터 Data를 수신했을 때 호출되는 함수
    ///
    /// 전송받은 데이터를 처리하는 peerDataHandler 클로저를 호출합니다.
    ///
    /// - Parameters:
    ///   - session: 데이터가 수신된 세션
    ///   - data: 수신된 데이터
    ///   - peerID: 발신자 Peer의 ID
    internal func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        if let handler = peerDataHandler {
            DispatchQueue.main.async {
                handler(data, peerID)
            }
        }
    }
    
    // MARK: - 아래 함수들은 MCSessionDelegate를 따르기 위해 작성된 함수들입니다.
    internal func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        print(#fileID, #function, #line, "\(streamName)")
    }
    
    internal func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        print(#fileID, #function, #line, "\(peerID.displayName)")
    }
    
    internal func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        print(#fileID, #function, #line, "\(peerID.displayName)")
    }
}

extension MPCSession: MCNearbyServiceAdvertiserDelegate {
    /// Peer로부터 세션 초대를 받으면 호출되는 함수
    /// - Parameters:
    ///   - advertiser: 세션에 참여하도록 초대한 advertiser
    ///   - peerID: 초대한 Peer의 ID
    ///   - context: 근처 피어로부터 수신된 임의의 데이터
    ///   - invitationHandler: 초대를 수락/거부할 지를 나타내고 연결할 세션 정보를 전달하는 클로저
    internal func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        mpcSessionSerialQueue.sync { [weak self] in
            guard let self else { return }
            // Accept the invitation only if the current number of peers is
            // less than the maximum.
            if self.mcSession.connectedPeers.count < self.maxNumPeers {
                // 초대를 수락하고, 연결할 세션 정보를 전달합니다.
                invitationHandler(true, self.mcSession)
            }
        }
    }
}

extension MPCSession: MCNearbyServiceBrowserDelegate {
    
    /// 근처 Peer를 찾았을 때 호출되는 함수
    /// - Parameters:
    ///   - browser: Peer를 찾은 browser 객체
    ///   - peerID: 찾은 Peer ID
    ///   - info: Peer의 advertiser의 정보
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        // Only connect with peers matched with the same `identityInfo` (both key and value).
        guard let identityValue = info?[MPCSessionConstants.kKeyIdentity],
              identityValue == discoveryInfoIdentity else {
            return
        }
        
        mpcSessionSerialQueue.sync { [weak self] in
            guard let self else { return }
            // Invite a new peer if the current number of peers is less than
            // the maximum.
            if self.mcSession.connectedPeers.count < self.maxNumPeers {
                browser.invitePeer(
                    peerID,
                    to: self.mcSession,
                    withContext: nil,
                    timeout: 10
                )
            }
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate를 따르기 위해 구현된 함수
    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        
    }
}
