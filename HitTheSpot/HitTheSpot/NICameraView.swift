//
//  NICameraView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NICameraView: View {
    let niOption: NIOption
    
    var body: some View {
        Text(niOption.description)
    }
}

#Preview {
    NICameraView(niOption: .extended)
//    NICameraView(niOption: .precise)
}
