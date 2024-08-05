//
//  MainView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/2/24.
//

import SwiftUI

struct MainView: View {
    @State private var state: ViewState = .direction
    @State private var lastViewState: ViewState = .direction
//    @State private var niSessionManager = NISessionManager(niStatus: .extended)
    let peerInfoUseCase: PeerInfoUseCase
    let myInfoUseCase: MyInfoUseCase
    let arUseCase: ARUseCase
    
    var body: some View {
        Group {
            switch state {
            case .direction:
//                DPMainDistanceView(
//                    peerInfoUseCase: peerInfoUseCase,
//                    niSessionManager: niSessionManager,
//                    arUseCase: arUseCase,
//                    modeChangeHandler: { updateViewState(to: .location) }
//                )
                MainDirectionView(
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase,
                    modeChangeHandler: { updateViewState(to: .location) }
                )

            case .location:
                MainLocationView(
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase,
                    modeChangeHandler: { updateViewState(to: .direction) }
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
        .onChange(of: state) { _, newValue in
            switch newValue {
            case .direction, .location:
                lastViewState = newValue
            case .nearby:
                break
            }
        }
        .onChange(of: peerInfoUseCase.state.nearbyObject) {
            guard let distance = peerInfoUseCase.state.nearbyObject?.distance else { return }
            
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
