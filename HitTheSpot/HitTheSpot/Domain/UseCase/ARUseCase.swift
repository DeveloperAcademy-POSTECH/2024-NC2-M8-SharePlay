//
//  ARUseCase.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/18/24.
//

import SwiftUI
import RealityKit

class ARUseCase {
    enum Action {
        case setARView(_ arView: ARView)
        case setARSession(_ arView: ARView)
        case startSession
        case stopSession
    }
    
    private let niManager: HSNearbyInteractManager
    private let arManager: HSARManager
    
    init(
        niManager: HSNearbyInteractManager,
        arManager: HSARManager
    ) {
        self.niManager = niManager
        self.arManager = arManager
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .setARView(let arView):
            arManager.setARView(arView)
        case .setARSession(let arView):
            niManager.setARSession(arView.session)
        case .startSession:
            arManager.startSession()
        case .stopSession:
            arManager.pauseSession()
        }
    }
}
