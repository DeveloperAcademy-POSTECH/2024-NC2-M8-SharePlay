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
    
    let activityManager: GroupActivityManager
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
                Task {
                    // SharePlay 혹은 FaceTime 연결여부 확인
                    // 1. SharePlay 중 -> .preferred: 새 그룹 활동으로 대치
                    // 2. FaceTime 중 -> .preferred: SharePlay 시작
                    // 3. local -> .local: SharePlay는 참여 안함/취소
                    // 4. None -> .needToAsk: SharePlay VC Sheet 호출
                    let outcome = await activityManager.askStatusForSharePlay()
                    isSharePlayPresented = outcome.isNeedToAsk
                }
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
        .tint(.accent)
    }
}

#Preview {
    MainHomeView(
        viewState: .constant(.home), 
        activityManager: GroupActivityManager(),
        arViewController: NIARViewController()
    )
    .preferredColorScheme(.dark)
}
