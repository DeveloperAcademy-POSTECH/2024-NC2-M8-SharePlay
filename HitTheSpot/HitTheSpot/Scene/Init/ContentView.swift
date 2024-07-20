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
            switch sharePlayUseCase.state.sessionState {
            case .joined:
                WaitingPeerView(
                    sharePlayUseCase: sharePlayUseCase,
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase
                )
            default:
                HomeView(
                    myInfoUseCase: myInfoUseCase,
                    sharePlayUseCase: sharePlayUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase
                )
            }
        }
        .onChange(of: sharePlayUseCase.state.participantCount) {
            myInfoUseCase.effect(.didPeerJoined)
        }
    }
}

//#Preview {
//    ContentView(niStatus: .extended)
//}
