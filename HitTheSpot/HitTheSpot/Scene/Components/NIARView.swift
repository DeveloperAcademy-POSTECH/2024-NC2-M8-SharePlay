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
    @State private var arViewController: NIARViewController
    private let niStatus: HSNIStatus
    private var niSessionManager: NISessionManager
    
    init(
        arViewController: NIARViewController,
        niStatus: HSNIStatus,
        niSessionManager: NISessionManager
    ) {
        self.arViewController = arViewController
        self.niStatus = niStatus
        self.niSessionManager = niSessionManager
    }
}

extension NIARView {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        arViewController.setARView(arView)
        niSessionManager.setARSession(arView.session)
        
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

@Observable
class NIARViewController {
    var arView: ARView?
    
    func setARView(_ arView: ARView) {
        self.arView = arView
    }
    
    func startSession() {
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
        arView?.session.run(configuration)
    }
    
    func pauseSession() {
        arView?.session.pause()
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
        arViewController: NIARViewController(),
        niStatus: .extended,
        niSessionManager: NISessionManager(niStatus: .extended)
    )
}
