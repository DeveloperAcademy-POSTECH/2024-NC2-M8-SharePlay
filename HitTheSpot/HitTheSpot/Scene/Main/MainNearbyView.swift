//
//  MainNearbyView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/3/24.
//

import SwiftUI

struct MainNearbyView: View {
    let sharePlayUseCase: SharePlayUseCase
    let peerInfoUseCase: PeerInfoUseCase
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Title()
                    .padding(.top, 80)
                
                Spacer()
                
                Literal.HSImage.title
                    .resizable()
                    .scaledToFit()
                    .opacity(0.2)
                    .padding(.bottom, 120)
            }
            .padding(.horizontal, 24)
            
            LottieView(filename: "NearbyEffect")
            
            VStack {
                Spacer()
                
                StopSharePlayBtn {
                    peerInfoUseCase.effect(.stopSharePlayBtnTap)
                    sharePlayUseCase.effect(.stopSharePlayBtnTap)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

extension MainNearbyView {
    @ViewBuilder
    func Title() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(peerInfoUseCase.state.profile?.name ?? "친구")와 가까워졌어요")
            HStack {
                Text("주변에서")
                Text("\(peerInfoUseCase.state.profile?.name ?? "친구")를 찾아보세요!")
                    .foregroundStyle(.accent)
                
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .font(.pretendard24)
    }
    
    @ViewBuilder
    func StopSharePlayBtn(action: @escaping () -> Void) -> some View {
        HSButton(
            text: "SharePlay 종료하기",
            icon: Literal.Icon.sharePlay,
            tint: .red1
        ) {
            action()
        }
    }
}

#Preview {
    MainNearbyView(sharePlayUseCase: .init(manager: .init()), peerInfoUseCase: .init(activityManager: .init(), niManager: .init()))
}
