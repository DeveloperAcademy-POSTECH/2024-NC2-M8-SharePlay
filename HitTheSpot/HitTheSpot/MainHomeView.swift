//
//  MainHomeView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainHomeView: View {
    @State private var arViewController = NIARViewController()
    @State private var niSessionManager: NISessionManager
    let niStatus: NIStatus
    
    init(niStatus: NIStatus) {
        self.niStatus = niStatus
        self._niSessionManager = State(wrappedValue: NISessionManager(niStatus: niStatus))
    }
    
    var body: some View {
        ZStack {
            NIARView(
                arViewController: arViewController,
                niStatus: niStatus,
                niSessionManager: niSessionManager
            )
            .ignoresSafeArea()
            
            // TODO: - 메인 홈 UI 구현
            VStack {
                VStack {
                    Text("HIT")
                    Text("THE")
                    Text("SPOT")
                }
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .padding()
                
                Spacer()
                
                NavigationLink {
                    SharePlayingView()
                } label: {
                    Label("SharePlay로 친구 찾기", systemImage: "shareplay")
                }
            }
            .padding()
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
    MainHomeView(niStatus: .extended)
}
