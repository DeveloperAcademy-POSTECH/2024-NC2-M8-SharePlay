//
//  NICameraView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NICameraView: View {
    let niStatus: NIStatus
    
    var body: some View {
        Text(niStatus.description)
    }
}

#Preview {
    NICameraView(niStatus: .extended)
//    NICameraView(niOption: .precise)
}
