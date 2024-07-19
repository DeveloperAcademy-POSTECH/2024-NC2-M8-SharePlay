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
    let arViewController: HSARManager
    @Bindable var niSessionManager: NISessionManager
    
    @State private var viewState: ViewState = .home
    @State private var lastViewState: ViewState = .home
    @State private var activityManager = GroupActivityManager()
    
    @Bindable private var sharePlayUseCase = SharePlayUseCase(manager: HSGroupActivityManager())
    
    @Bindable private var locationUseCase = MyInfoUseCase(
        activityManager: HSGroupActivityManager(),
        locationManager: HSLocationManager()
    )
    
    var body: some View {
        VStack {
            switch viewState {
            case .home:
                MainHomeView(
                    sharePlayUseCase: sharePlayUseCase,
                    viewState: $viewState,
                    arViewController: arViewController
                )
            case .distance:
                MainDistanceView(
                    niSessionManager: niSessionManager,
                    arViewController: arViewController,
                    modeChangeHandler: { updateViewState(to: .location) }
                )
            case .location:
                MainLocationView(
                    myInfoUseCase: locationUseCase,
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
        .onChange(of: viewState) { _, newValue in
            switch newValue {
            case .home, .distance, .location:
                lastViewState = newValue
            case .nearby:
                break
            }
        }
        .onChange(of: niSessionManager.distance) {
            guard let distance = niSessionManager.distance else { return }
            
            switch distance {
            case 0..<ThreshHold.nearByDistance:
                updateViewState(to: .nearby)
            default:
                updateViewState(to: lastViewState)
            }
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
        arViewController: HSARManager(),
        niSessionManager: NISessionManager(niStatus: .extended)
    )
    .preferredColorScheme(.dark)
}
