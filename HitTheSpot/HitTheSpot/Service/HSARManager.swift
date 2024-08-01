//
//  HSARManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/19/24.
//

import Foundation
import RealityKit
import ARKit

@Observable
class HSARManager {
    var arView: ARView?
    
    func setARView(_ arView: ARView) {
        self.arView = arView
    }
    
    func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.isCollaborationEnabled = false
        configuration.userFaceTrackingEnabled = false
        configuration.initialWorldMap = nil
        configuration.environmentTexturing = .automatic
        
        arView?.session.run(configuration)
    }
    
    func pauseSession() {
        arView?.session.pause()
    }
}

extension HSARView.Coordinator {
    func placeSpheresInView(
        _ arView: ARView,
        _ worldTransform: simd_float4x4
    ) {}
            
    func placeTextInView(
        _ arView: ARView,
        _ worldTransform: simd_float4x4,
        name: String,
        distance: Float
    ) {}
    
    func updatePeerAnchor(
        arView: ARView,
        currentWorldTransform: simd_float4x4?,
        name: String,
        distance: Float
    ) {}
}
