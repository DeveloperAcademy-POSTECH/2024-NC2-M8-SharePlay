//
//  HomeView.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/20/24.
//

import SwiftUI

struct HomeView: View {
    @Bindable var myInfoUseCase: MyInfoUseCase
    @State private var isPresented: Bool = false
    
    let sharePlayUseCase: SharePlayUseCase
    let peerInfoUseCase: PeerInfoUseCase
    let arUseCase: ARUseCase
    
    var body: some View {
        ZStack {
            HSARView(arUseCase: arUseCase)
                .ignoresSafeArea()
            
            Content(
                sharePlayUseCase: sharePlayUseCase,
                isPresented: $isPresented
            )
        }
        .sheet(isPresented: $isPresented) {
            Text("1")
        }
    }
}

// MARK: - Content
extension HomeView {
    struct Content: View {
        @Bindable var sharePlayUseCase: SharePlayUseCase
        @Binding var isPresented: Bool
        
        var body: some View {
            ZStack {
                Background()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        ProfileButton {
                            isPresented.toggle()
                        }
                    }
                    .padding(.top, 56)
                    
                    VStack {
                        Spacer()
                        MainContents()
                        Spacer()
                    }
                    
                    VStack(spacing: 16) {
                        SharePlayButton {
                            sharePlayUseCase.effect(.startSharePlayBtnTap)
                        }
                        
                        Text("나의 위치가 공유됩니다")
                            .font(.pretendard16)
                            .foregroundStyle(.accent)
                    }
                    .padding(.bottom, 80)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

extension HomeView.Content {
    @ViewBuilder
    func Background() -> some View {
        Literal.HSImage.mainHomeBg
            .resizable()
            .scaledToFill()
            .opacity(0.4)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    func MainContents() -> some View {
        VStack(alignment: .leading){
            Text("친구 찾기 어려울 땐, 여기로 모여!")
                .font(.pretendard20)
                .padding(.bottom, 40)
                .foregroundColor(.white)
            
            HStack {
                Literal.HSImage.titleWithLogo
                    .frame(height: 234)
                    .scaledToFit()
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func ProfileButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Literal.Icon.profile
                .resizable()
                .frame(width: 36, height: 36)
                .foregroundStyle(.white)
        }
    }
    
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
                        icon: { Literal.Icon.sharePlay }
                    )
                    .font(.pretendard20)
                    .foregroundColor(.black)
                )
        }
    }
}

#Preview {
    HomeView(
        myInfoUseCase: .init(activityManager: .init(), locationManager: .init()), sharePlayUseCase: .init(manager: .init()),
        peerInfoUseCase: .init(activityManager: .init(), niManager: .init()),
        arUseCase: .init(niManager: .init(), arManager: .init())
    )
//    HomeView.Content(sharePlayUseCase: .init(manager: .init()))
}
