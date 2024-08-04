//
//  MainLocationView.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/3/24.
//

import SwiftUI
import MapKit

struct MainLocationView: View {
    @Bindable var myInfoUseCase: MyInfoUseCase
    @Bindable var peerInfoUseCase: PeerInfoUseCase
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )
    @Namespace var mapScope
    
    let arUseCase: ARUseCase
    let modeChangeHandler: () -> Void
    
    var body: some View {
        ZStack {
            HSMap(position: $cameraPosition, scope: mapScope)
            
            Group {
                RadialGradientCover()
                    .allowsHitTesting(false)
                
                VStack {
                    TitleLabel(pearName: peerInfoUseCase.state.profile?.name ?? "친구")
                        .allowsTightening(false)
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        Color.clear.frame(width: 50, height: 50)
                        Spacer()
                        ShowDistanceViewButton { modeChangeHandler() }
                        Spacer()
                        HSMapControls(scope: mapScope)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 60)
            }
        }
        .mapScope(mapScope)
    }
}

extension MainLocationView {
    @ViewBuilder
    func HSMap(position: Binding<MapCameraPosition>, scope: Namespace.ID) -> some View {
        Map(position: position, scope: scope) {
            
            if let myLocation = myInfoUseCase.state.location {
                Annotation("나", coordinate: .init(myLocation)) {
                    Marker()
                }
            }
            
            if let peerInfo = peerInfoUseCase.state.profile,
               let peerLocation = peerInfoUseCase.state.location
            {
                Annotation(peerInfo.name, coordinate: .init(peerLocation)) {
                    Marker(isPeer: true)
                }
            }
        }
        .mapControlVisibility(.hidden)
    }

    @ViewBuilder
    func HSMapControls(scope: Namespace.ID) -> some View {
        VStack(alignment: .trailing, spacing: 16) {
            Group {
                MapCompass(scope: scope)
                
                MapPitchToggle(scope: scope)
                
                MapUserLocationButton(scope: scope)
                    .buttonBorderShape(.buttonBorder)
                    .clipShape(Circle())
            }
            .frame(width: 50, height: 50)
        }
    }
    
    @ViewBuilder
    func Marker(isPeer: Bool = false) -> some View {
        ZStack {
            Circle()
                .fill(isPeer ? .accent : .white)
                .frame(width: 40, height: 40)
            Circle()
                .fill(isPeer ? .white : .accent)
                .frame(width: 36, height: 36)
        }
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
    
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
                .padding(.horizontal, 16)
            
            // stroke
            Circle()
                .stroke(.white, lineWidth: 1)
                .padding(.horizontal, 16)
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
                        .foregroundStyle(.accent)
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
                Literal.Icon.distance
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
    MainLocationView(myInfoUseCase: .init(activityManager: .init(), niManager: .init(), locationManager: .init()), peerInfoUseCase: .init(activityManager: .init(), niManager: .init()), arUseCase: .init(niManager: .init(), arManager: .init()), modeChangeHandler: {})
}
