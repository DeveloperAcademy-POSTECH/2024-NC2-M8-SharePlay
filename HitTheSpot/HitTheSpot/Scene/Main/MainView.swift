//
//  MainView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/2/24.
//

import SwiftUI

struct MainView: View {
    @State private var state: ViewState = .direction
    
    var body: some View {
        switch state {
        case .direction:
            MainDirectionView()
        case .location:
            MainLocationView()
        case .nearby:
            MainNearbyView()
        }
    }
}

extension MainView {
    enum ViewState {
        case direction
        case location
        case nearby
    }
}

#Preview {
    MainView()
}
