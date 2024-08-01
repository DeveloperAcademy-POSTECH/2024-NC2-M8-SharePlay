//
//  ContentView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/16/24.
//

import SwiftUI
import NearbyInteraction

enum ViewState {
    case home
    case waiting
    case distance
    case location
    case nearby
}

struct ContentView: View {
    @Bindable var sharePlayUseCase: SharePlayUseCase
    @State private var viewState: ViewState = .home
    
    private let myInfoUseCase: MyInfoUseCase
    private let peerInfoUseCase: PeerInfoUseCase
    private let arUseCase: ARUseCase
    
    init(
        sharePlayUseCase: SharePlayUseCase,
        myInfoUseCase: MyInfoUseCase,
        peerInfoUseCase: PeerInfoUseCase,
        arUseCase: ARUseCase
    ) {
        self.sharePlayUseCase = sharePlayUseCase
        self.myInfoUseCase = myInfoUseCase
        self.peerInfoUseCase = peerInfoUseCase
        self.arUseCase = arUseCase
    }
    
    var body: some View {
        
        // localJoined and Active Participant >= 2 >> MainDistanceView
        // localJoined and Active Participant == 1 >> WaitingView
        // localWaiting, localInvalidated >> HomeView
        
        
        Group {
            switch sharePlayUseCase.state.sharePlayState {
            case .notJoined:
                HomeView(
                    myInfoUseCase: myInfoUseCase,
                    sharePlayUseCase: sharePlayUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase
                )
            case .onlyLocal:
                WaitingPeerView(
                    sharePlayUseCase: sharePlayUseCase,
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase
                )
            case .localWithPeer:
                Text("Connected")
            }
        }
        .onChange(of: sharePlayUseCase.state.sharePlayState) { oldValue, newValue in
            if newValue == .localWithPeer {
                myInfoUseCase.effect(.didPeerJoined)
            }
        }
    }
}

//#Preview {
//    ContentView(niStatus: .extended)
//}
