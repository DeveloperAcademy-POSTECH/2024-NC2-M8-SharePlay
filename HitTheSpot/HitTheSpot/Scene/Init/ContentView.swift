//
//  ContentView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/16/24.
//

import SwiftUI
import NearbyInteraction

struct ContentView: View {
    @Bindable var sharePlayUseCase: SharePlayUseCase
    
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
                MainView()
            }
        }
        .onChange(of: sharePlayUseCase.state.sharePlayState) { oldValue, newValue in
            if newValue == .localWithPeer {
                myInfoUseCase.effect(.didPeerJoined)
            }
        }
    }
}
