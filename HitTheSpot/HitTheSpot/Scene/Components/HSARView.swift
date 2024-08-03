//
//  NIARView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI
import ARKit
import RealityKit

struct HSARView: UIViewRepresentable {
    let arUseCase: ARUseCase
    
    init(arUseCase: ARUseCase) {
        self.arUseCase = arUseCase
    }
}

extension HSARView {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        arUseCase.effect(.setARView(arView))
        arUseCase.effect(.setARSession(arView))
    
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
        var parent: HSARView
        
        init(_ parent: HSARView) {
            self.parent = parent
        }
    }
}

#Preview {
    HSARView(arUseCase: 
        .init(
            niManager: HSNearbyInteractManager(),
            arManager: HSARManager()
        )
    )
}
