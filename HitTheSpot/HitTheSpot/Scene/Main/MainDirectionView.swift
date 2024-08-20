//
//  MainDistanceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/3/24.
//

import SwiftUI
import CoreLocation

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
    
    var distance: CLLocationDistance {
        peerInfoUseCase.state.location?.distance(from: myInfoUseCase.state.location) ?? 0
    }
    
    var body: some View {
        GeometryReader { gr in
            ZStack {
                HSARView(arUseCase: arUseCase)
                    .ignoresSafeArea()
                
                ArrowOverlay(
                    gr: gr,
                    rotateAngle: peerInfoUseCase.state.nearbyObject?.horizontalAngle
                )
                
                VStack {
                    TitleLabel(
                        peerName: peerInfoUseCase.state.profile?.name ?? "친구",
                        distance: peerInfoUseCase.state.nearbyObject?.distance ?? Float(distance)
                    )
                    
                    Spacer()
                    
                    ShowLocationViewButton {
                        withAnimation {
                            modeChangeHandler()
                        }
                    }
                }
                .padding(.vertical, 60)
            }
        }
        .onAppear {
            arUseCase.effect(.startSession)
        }
        .onDisappear {
            arUseCase.effect(.stopSession)
        }
    }
}

extension MainDirectionView {
    @ViewBuilder
    func ArrowOverlay(gr: GeometryProxy, rotateAngle: Float?) -> some View {
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
            
            if rotateAngle != nil {
                Circle()
                    .stroke(.white, lineWidth: 1)
                
                Literal.HSImage.arrow
                
                HStack {
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 16)
                        .offset(x: -8)
                    Spacer()
                }
                .rotationEffect(.radians(.pi / 2))
                
            } else {
                LottieView(filename: "Searching")
                    .scaleEffect(2)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 16)
        .rotationEffect(Angle(radians: Double(rotateAngle ?? 0)))
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
