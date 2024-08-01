//
//  WaitingPeerView.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/20/24.
//

import SwiftUI

struct WaitingPeerView: View {
    @Bindable var sharePlayUseCase: SharePlayUseCase
    @Bindable var peerInfoUseCase: PeerInfoUseCase
    let myInfoUseCase: MyInfoUseCase
    
    init(
        sharePlayUseCase: SharePlayUseCase,
        myInfoUseCase: MyInfoUseCase,
        peerInfoUseCase: PeerInfoUseCase
    ) {
        self.sharePlayUseCase = sharePlayUseCase
        self.myInfoUseCase = myInfoUseCase
        self.peerInfoUseCase = peerInfoUseCase
    }
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 40) {
                ParticipantCountView()
                
                MyProfile()
            }
        }
    }
}

extension WaitingPeerView {
    @ViewBuilder
    func Background() -> some View {
        Literal.HSImage.mainHomeBg
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .background(.black)
    }
    
    @ViewBuilder
    func ParticipantCountView() -> some View {
        HStack {
            Literal.Icon.sharePlay
                .font(.system(size: 20))
            
            Text("\(sharePlayUseCase.state.participantCount)명 참여 중")
                .font(.pretendard20)
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder
    func MyProfile() -> some View {
        VStack(spacing: 16) {
            if let imgData = myInfoUseCase.state.profile?.imgData,
               let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 91, height: 91)
                    .clipShape(Circle())
            } else {
                Literal.HSImage.profile
                    .resizable()
                    .frame(width: 91, height: 91)
            }
            
            Text(myInfoUseCase.state.profile?.name ?? "None")
                .font(.pretendard20)
                .foregroundStyle(.white)
            
            HStack {
                Literal.Icon.sharePlay
                    .font(.system(size: 20))
                
                Text("참여 중")
                    .font(.pretendard16)
            }
            .foregroundStyle(.accent)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 37)
        .background(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    WaitingPeerView(
        sharePlayUseCase: .init(manager: .init()),
        myInfoUseCase: .init(
            activityManager: .init(),
            niManager: .init(),
            locationManager: .init()
        ),
        peerInfoUseCase: .init(activityManager: .init(), niManager: .init()))
}
