//
//  MainHomeView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainHomeView: View {
    @Bindable var sharePlayUseCase: SharePlayUseCase
    @Binding var viewState: MainView.ViewState
    let arViewController: HSARManager
    
    var body: some View {
        ZStack {
            Literal.HSImage.mainHomeBg
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
                    
                    Literal.HSImage.titleWithLogo
                        .frame(height: 225)
                        .scaledToFit()
                }
                
                Spacer()
                Spacer()
                
                SharePlayButton {
                    sharePlayUseCase.effect(.startSharePlayBtnTap)
                }
                .padding(.bottom, 80)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented:
                .init(
                    get: { sharePlayUseCase.state.isSheetPresented },
                    set: { _ in sharePlayUseCase.effect(.bindIsSheetPresented) }
                )
            )
        {
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
                        icon: { Literal.Icon.sharePlay }
                    )
                    .font(.pretendard20)
                    .foregroundColor(.black)
                )
        }
    }
}

#Preview {
    MainHomeView(
        sharePlayUseCase: SharePlayUseCase(
            manager: HSGroupActivityManager()
        ),
        viewState: .constant(.home),
        arViewController: HSARManager()
    )
    .preferredColorScheme(.dark)
}
