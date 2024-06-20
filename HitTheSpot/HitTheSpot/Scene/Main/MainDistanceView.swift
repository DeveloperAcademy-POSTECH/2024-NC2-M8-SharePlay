//
//  MainDistanceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainDistanceView: View {
    var modeChangeHandler: (() -> Void)?
    @State private var rotateAngle: Double = 0
    
    let peerName: String = "뿌"
    let distance: Double = 20.8888
    
    var body: some View {
        ZStack {
            VStack {
                TitleLabel(peerName: peerName, distance: distance)
                
                Spacer()
                
                ShowLocationViewButton {
                    modeChangeHandler?()
                }
            }
            .padding(.vertical, 60)
            
            ArrowOverlay()
                .rotationEffect(.degrees(rotateAngle))
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
            
            Image("DirectionArrow")
            
            Circle()
                .fill(Color.accent)
                .frame(width: 16)
                .offset(y: -180)
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func TitleLabel(peerName: String, distance: Double) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(peerName) 만나기까지")
                    .font(.pretendard24)
                    
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
                Image(systemName: "smallcircle.filled.circle")
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
    MainDistanceView()
        .preferredColorScheme(.dark)
}
