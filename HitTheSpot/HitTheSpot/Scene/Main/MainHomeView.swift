//
//  MainHomeView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainHomeView: View {
    @Binding var viewState: MainView.ViewState
    @State private var isSharePlayPresented = false
    
    let arViewController: NIARViewController
    
    var body: some View {
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
            
            SharePlayButton {
                isSharePlayPresented = true
            }
        }
        .padding()
        .sheet(isPresented: $isSharePlayPresented) {
            GroupActivityShareSheet {
                ShareLocationActivity()
            }
            .onAppear {
                arViewController.pauseSession()
            }
            .onDisappear {
                arViewController.startSession()
            }
        }
    }
}

extension MainHomeView {
    @ViewBuilder
    func SharePlayButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Label(
                title: { Text("Start SharePlay") },
                icon: { Image(systemName: "shareplay") }
            )
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }
}

#Preview {
    MainHomeView(
        viewState: .constant(.home),
        arViewController: NIARViewController()
    )
    .preferredColorScheme(.dark)
}
