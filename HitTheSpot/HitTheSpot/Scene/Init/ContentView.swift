////
////  ContentView.swift
////  HitTheSpot
////
////  Created by 남유성 on 6/16/24.
////
//
//import SwiftUI
//import NearbyInteraction
//
//struct ContentView: View {
//    private let sharePlayUseCase: SharePlayUseCase
//    private let myInfoUseCase: MyInfoUseCase
//    private let peerInfoUseCase: PeerInfoUseCase
//    private let arUseCase: ARUseCase
//    
//    init(
//        sharePlayUseCase: SharePlayUseCase,
//        myInfoUseCase: MyInfoUseCase,
//        peerInfoUseCase: PeerInfoUseCase,
//        arUseCase: ARUseCase
//    ) {
//        self.sharePlayUseCase = sharePlayUseCase
//        self.myInfoUseCase = myInfoUseCase
//        self.peerInfoUseCase = peerInfoUseCase
//        self.arUseCase = arUseCase
//    }
//    
//    var body: some View {
//        ZStack {
//            NIARView(arUseCase: arUseCase)
//                .ignoresSafeArea()
//            
//            MainView(
//                arViewController: arViewController,
//                niSessionManager: niSessionManager
//            )
//        }
//        .onAppear {
//            arViewController.startSession()
//        }
//        .onDisappear {
//            arViewController.pauseSession()
//        }
//    }
//}
//
//#Preview {
////    ContentView(niStatus: .extended)
//}
