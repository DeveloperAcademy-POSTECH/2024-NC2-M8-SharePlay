//
//  MainView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/2/24.
//

import SwiftUI

struct MainView: View {
    @State private var state: ViewState = .direction
    let peerInfoUseCase: PeerInfoUseCase
    let myInfoUseCase: MyInfoUseCase
    let arUseCase: ARUseCase
    
    var body: some View {
        switch state {
        case .direction:
            MainDirectionView(
                myInfoUseCase: myInfoUseCase,
                peerInfoUseCase: peerInfoUseCase,
                arUseCase: arUseCase, 
                modeChangeHandler: { updateViewState(to: .location) }
            )
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

extension MainView {
    func updateViewState(to viewState: ViewState) {
        withAnimation { self.state = viewState }
    }
}

#Preview {
    MainView(
        peerInfoUseCase: .init(
            activityManager: .init(),
            niManager: .init()
        ),
        myInfoUseCase: .init(
            activityManager: .init(),
            niManager: .init(),
            locationManager: .init()
        ),
        arUseCase: .init(
            niManager: .init(),
            arManager: .init()
        )
    )
    .preferredColorScheme(.dark)
}
