//
//  NICameraView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NICameraAssistanceView: View {
    @State private var niSessionManager: NISessionManager
    
    let niStatus: NIStatus
    
    init(niStatus: NIStatus) {
        self.niStatus = niStatus
        self._niSessionManager = State(wrappedValue: NISessionManager(niStatus: niStatus))
    }
    
    var body: some View {
        Text(niStatus.description)
    }
}

#Preview {
    NICameraAssistanceView(niStatus: .extended)
//    NICameraView(niOption: .precise)
}
