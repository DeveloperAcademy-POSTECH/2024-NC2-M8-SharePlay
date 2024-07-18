//
//  NICameraView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NICameraAssistanceView: View {
    var niSessionManager: NISessionManager
    
    let niStatus: HSNIStatus
    
    var body: some View {
        NIARView(
            arViewController: NIARViewController(),
            niStatus: niStatus,
            niSessionManager: niSessionManager
        )
    }
}

#Preview {
    NICameraAssistanceView(
        niSessionManager: NISessionManager(niStatus: .extended),
        niStatus: .extended
    )
}
