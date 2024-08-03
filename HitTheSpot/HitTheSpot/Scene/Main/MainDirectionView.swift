//
//  MainDistanceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/3/24.
//

import SwiftUI

struct MainDirectionView: View {
    @Bindable var myInfoUseCase: MyInfoUseCase
    @Bindable var peerInfoUseCase: PeerInfoUseCase
    let arUseCase: ARUseCase
    let modeChangeHandler: () -> Void
    
    init(
        myInfoUseCase: MyInfoUseCase,
        peerInfoUseCase: PeerInfoUseCase,
        arUseCase: ARUseCase,
        modeChangeHandler: @escaping () -> Void
    ) {
        self.myInfoUseCase = myInfoUseCase
        self.peerInfoUseCase = peerInfoUseCase
        self.arUseCase = arUseCase
        self.modeChangeHandler = modeChangeHandler
    }
    
    var body: some View {
        ZStack {
            HSARView(arUseCase: arUseCase)
                .ignoresSafeArea()
            
            VStack {
                TitleLabel(
                    peerName: peerInfoUseCase.state.profile?.name ?? "",
                    distance: peerInfoUseCase.state.nearbyObject?.distance ?? 0
                )
                
                Spacer()
                
                ShowLocationViewButton {
                    modeChangeHandler()
                }
            }
            .padding(.vertical, 60)
            
            ArrowOverlay()
                .rotationEffect(
                    Angle(radians: Double(peerInfoUseCase.state.nearbyObject?.horizontalAngle ?? 0))
                )
        }
        .onAppear {
            arUseCase.effect(.startSession)
//            niSessionManager.startup()
        }
        .onDisappear {
            arUseCase.effect(.stopSession)
        }
    }
}

extension MainDirectionView {
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
    MainDirectionView(
        myInfoUseCase: .init(
            activityManager: .init(),
            niManager: .init(),
            locationManager: .init()
        ),
        peerInfoUseCase: .init(
            activityManager: .init(),
            niManager: .init()
        ),
        arUseCase: .init(
            niManager: .init(),
            arManager: .init()
        ),
        modeChangeHandler: {}
    )
    .preferredColorScheme(.dark)
}
