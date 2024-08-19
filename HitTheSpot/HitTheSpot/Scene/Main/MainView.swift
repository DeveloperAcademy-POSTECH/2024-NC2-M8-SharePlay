//
//  MainView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/2/24.
//

import SwiftUI

struct MainView: View {
    @State private var state: ViewState = .init()
    let peerInfoUseCase: PeerInfoUseCase
    let myInfoUseCase: MyInfoUseCase
    let arUseCase: ARUseCase
    
    var body: some View {
        Group {
            switch state.state {
            case .direction:
                MainDirectionView(
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase,
                    modeChangeHandler: { state.update(to: .location) }
                )

            case .location:
                MainLocationView(
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase,
                    modeChangeHandler: { state.update(to: .direction) }
                )
                
            case .nearby:
                MainNearbyView(peerInfoUseCase: peerInfoUseCase)
            }
        }
        .onAppear {
            myInfoUseCase.effect(.startMonitorLocation)
        }
        .onDisappear {
            myInfoUseCase.effect(.stopMonitorLocation)
        }
        .onChange(of: peerInfoUseCase.state.isNearby) { _, isNearby in
            isNearby ? state.update(to: .nearby) : state.rollBack()
        }
    }
}

extension MainView {
    @Observable
    class ViewState {
        enum StateType {
            case direction
            case location
            case nearby
        }
        
        private(set) var state: StateType = .direction
        @ObservationIgnored private(set) var lastState: StateType = .direction
            
        func update(to viewState: StateType) {
            lastState = state
            withAnimation { self.state = viewState }
        }
        
        func rollBack() {
            withAnimation { self.state = self.lastState }
        }
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
