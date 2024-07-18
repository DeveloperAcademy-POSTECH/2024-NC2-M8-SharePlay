//
//  ContentView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/16/24.
//

import SwiftUI
import NearbyInteraction

struct ContentView: View {
    private let arViewController = NIARViewController()
    private let niSessionManager: NISessionManager
    
    let niStatus: HSNIStatus
    
    init(niStatus: HSNIStatus) {
        self.niStatus = niStatus
        self.niSessionManager = NISessionManager(niStatus: niStatus)
    }
    
    var body: some View {
        ZStack {
            NIARView(
                arViewController: arViewController,
                niStatus: niStatus,
                niSessionManager: niSessionManager
            )
            .ignoresSafeArea()
            
            MainView(
                arViewController: arViewController,
                niSessionManager: niSessionManager
            )
        }
        .onAppear {
            arViewController.startSession()
        }
        .onDisappear {
            arViewController.pauseSession()
        }
    }
}

#Preview {
    ContentView(niStatus: .extended)
}
