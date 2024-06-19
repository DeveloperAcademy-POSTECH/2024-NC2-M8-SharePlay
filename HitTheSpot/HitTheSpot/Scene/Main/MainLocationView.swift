//
//  MainLocationView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI
import MapKit

struct MainLocationView: View {
    var modeChangeHandler: (() -> Void)?
    
    let peerName: String = "라뮤"
    
    var body: some View {
        ZStack {
            Map()
            
            RadialGradientCover()
            
            VStack {
                TitleLabel(pearName: peerName)
                
                Spacer()
                
                ShowDistanceViewButton {
                    modeChangeHandler?()
                }
            }
            .padding(.vertical, 60)
        }
    }
}

extension MainLocationView {
    @ViewBuilder
    func RadialGradientCover() -> some View {
        ZStack {
            // 그라디언트 처리
            RadialGradient(
                gradient: Gradient(
                    colors: [
                        .black.opacity(0),
                        .black
                    ]
                ),
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .opacity(0.8)
            .ignoresSafeArea()
            
            // 원
            Circle()
                .fill(Color.white)
                .blendMode(.destinationOut)
                .frame(width: 360, height: 360)
            
            // stroke
            Circle()
                .stroke(.white, lineWidth: 1)
                .frame(width: 360, height: 360)
        }
        .compositingGroup()
    }
    
    @ViewBuilder
    func TitleLabel(pearName: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("지도에서")
                HStack {
                    Text("나와 \(pearName)의")
                    Text("위치를 확인하세요")
                        .foregroundStyle(.green)
                }
            }
            .foregroundStyle(.white)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.leading, 24)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func ShowDistanceViewButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "arrow.up.circle")
                Text("거리 보기")
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
    MainLocationView()
}
