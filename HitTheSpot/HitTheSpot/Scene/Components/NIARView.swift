//
//  NIARView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI
import ARKit
import RealityKit

struct NIARView: UIViewRepresentable {
    let arUseCase: ARUseCase
    
    init(arUseCase: ARUseCase) {
        self.arUseCase = arUseCase
    }
}

extension NIARView {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        arUseCase.effect(.setARView(arView))
    
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

#Preview {
    NIARView(arUseCase: 
        .init(
            niManager: HSNearbyInteractManager(),
            arManager: HSARManager()
        )
    )
}
