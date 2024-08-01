//
//  MainDistanceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainDistanceView: View {
    @Bindable var niSessionManager: NISessionManager
    let arViewController: HSARManager
    
    var modeChangeHandler: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack {
                TitleLabel(
                    peerName: niSessionManager.connectedPeerName ?? "",
                    distance: niSessionManager.distance ?? 0
                )
                
                Spacer()
                
                ShowLocationViewButton {
                    modeChangeHandler?()
                }
            }
            .padding(.vertical, 60)
            
            ArrowOverlay()
                .rotationEffect(
                    Angle(radians: Double(niSessionManager.horizontalAngle ?? 0))
                )
        }
        .onAppear {
            arViewController.startSession()
            niSessionManager.startup()
        }
        .onDisappear {
            arViewController.pauseSession()
        }
    }
}

extension MainDistanceView {
    @ViewBuilder
    func ArrowOverlay() -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(
                            colors: [
                                .init(hex: "737373").opacity(0),
                                .init(hex: "F2F2F2").opacity(0.3)
                            ]
                        ),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
            
            Circle()
                .stroke(.white, lineWidth: 1)
            
            Literal.HSImage.arrow
            
            Circle()
                .fill(Color.accent)
                .frame(width: 16)
                .offset(y: -180)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func TitleLabel(peerName: String, distance: Float) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(peerName) 만나기까지")
                    .font(.pretendard24)
                    .foregroundStyle(.white)
                    
                HStack(alignment: .bottom) {
                    Text(String(format: "%.1f", distance))
                        .font(.syncopateRegular70)
                    Text("m")
                        .font(.syncopateRegular40)
                }
                .foregroundStyle(.accent)
            }
            
            Spacer()
        }
        .padding(.leading, 24)
    }
    
    @ViewBuilder
    func ShowLocationViewButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Literal.Icon.location
                Text("위치 보기")
            }
            .foregroundStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(.white)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    MainDistanceView(
        niSessionManager: NISessionManager(niStatus: .extended),
        arViewController: HSARManager()
    )
    .preferredColorScheme(.dark)
}
