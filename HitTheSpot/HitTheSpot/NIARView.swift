//
//  NIARView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI
import ARKit
import RealityKit
import Combine
import UIKit

struct NIARView: UIViewRepresentable {
    let niStatus: NIStatus
    var niSessionManager: NISessionManager
    
    init(niStatus: NIStatus, niSessionManager: NISessionManager) {
        self.niStatus = niStatus
        self.niSessionManager = niSessionManager
    }
}

extension NIARView {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        self.niSessionManager.setARSession(arView.session)
        
        // Create a world-tracking configuration to the
        // AR session requirements for Nearby Interaction.
        // For more information,
        // see the `setARSession` function of `NISession`.
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.isCollaborationEnabled = false
        configuration.userFaceTrackingEnabled = false
        configuration.initialWorldMap = nil
        configuration.environmentTexturing = .automatic
        
        // Run the view's AR session.
        arView.session.run(configuration)
        
        let blurView = UIVisualEffectView(
            effect: UIBlurEffect(
                style: .systemUltraThinMaterialDark
            )
        )
        
        blurView.frame = arView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(blurView)
    
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: NIARView
        
        init(_ parent: NIARView) {
            self.parent = parent
        }
    }
}

extension NIARView.Coordinator {
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

#Preview {
    NIARView(
        niStatus: .extended,
        niSessionManager: NISessionManager(niStatus: .extended)
    )
}
