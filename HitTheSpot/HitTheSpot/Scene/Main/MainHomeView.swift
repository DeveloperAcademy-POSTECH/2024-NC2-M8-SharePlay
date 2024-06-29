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
        ZStack {
            Image("MainFilter")
                .resizable()
                .scaledToFill()
                .opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Spacer()
                Spacer()
                
                VStack(alignment: .leading){
                    Text("친구 찾기 어려울 땐, 여기로 모여!")
                        .font(.pretendard20)
                        .padding(.bottom, 40)
                        .foregroundColor(.white)
                    
                    Image("MainTitle")
                        .frame(height: 225)
                        .scaledToFit()
                }
                
                Spacer()
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
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 24)
        }
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
            RoundedRectangle(cornerRadius: 50)
                .frame(height: 58)
                .foregroundColor(.accentColor)
                .overlay(
                    Label(
                        title: { Text("SharePlay로 친구 찾기") },
                        icon: { Image(systemName: "shareplay") }
                    )
                    .font(.pretendard20)
                    .foregroundColor(.black)
                )
        }
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
