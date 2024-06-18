//
//  MainView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

extension MainView {
    enum ViewState {
        case home
        case distance
        case location
        case nearby
    }
}

struct MainView: View {
    let arViewController: NIARViewController
    let niSessionManager: NISessionManager
    
    @State private var viewState: ViewState = .home
    
    var body: some View {
        switch viewState {
        case .home:
            MainHomeView(
                viewState: $viewState,
                arViewController: arViewController
            )
        case .distance:
            MainDistanceView()
        case .location:
            MainLocationView()
        case .nearby:
            MainNearbyView()
        }
    }
}

#Preview {
    MainView(
        arViewController: NIARViewController(),
        niSessionManager: NISessionManager(niStatus: .extended)
    )
}
