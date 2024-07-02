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
    
    @State private var viewState: ViewState = .distance
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
                MainDistanceView(
                    niSessionManager: niSessionManager,
                    modeChangeHandler: { updateViewState(to: .location) }
                )
            case .location:
                MainLocationView(
                    activityManager: activityManager,
                    arViewController: arViewController,
                    modeChangeHandler: { updateViewState(to: .distance) }
                )
            case .nearby:
                MainNearbyView()
            }
        }
        .onAppear {
            activityManager.sharePlayJoinedHandler = { updateViewState(to: .distance) }
            activityManager.sharePlayInvalidateHandler = { updateViewState(to: .home) }
        }
    }
}

extension MainView {
    func updateViewState(to viewState: ViewState) {
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
    .preferredColorScheme(.dark)
}
