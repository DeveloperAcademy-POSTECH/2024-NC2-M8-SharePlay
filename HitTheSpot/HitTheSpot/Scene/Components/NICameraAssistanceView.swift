//
//  NICameraView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NICameraAssistanceView: View {
    let arUseCase: ARUseCase
    
    var body: some View {
        HSARView(arUseCase: arUseCase)
    }
}

#Preview {
    NICameraAssistanceView(arUseCase:
        .init(
            niManager: NISessionManager(),
            arManager: ARManager()
        )
    )
}
