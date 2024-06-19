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
    @State private var activityManager = GroupActivityManager()
    
    var body: some View {
        VStack {
            Text(activityManager.statusDescription)
                .font(.largeTitle.bold())
                .foregroundStyle(.red)
            
            switch viewState {
            case .home:
                MainHomeView(
                    viewState: $viewState,
                    activityManager: activityManager,
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
        .onAppear {
            activityManager.sharePlayJoinedHandler = { updateView(to: .distance) }
            activityManager.sharePlayInvalidateHandler = { updateView(to: .home) }
        }
    }
}

extension MainView {
    func updateView(to viewState: ViewState) {
        withAnimation {
            self.viewState = viewState
        }
    }
}

#Preview {
    MainView(
        arViewController: NIARViewController(),
        niSessionManager: NISessionManager(niStatus: .extended)
    )
}
