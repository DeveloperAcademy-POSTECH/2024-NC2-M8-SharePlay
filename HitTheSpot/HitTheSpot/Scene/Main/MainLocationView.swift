//
//  MainLocationView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI
import MapKit

struct MainLocationView: View {
    @Bindable var activityManager: GroupActivityManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var locationManager = LocationManager()
    
    let arViewController: NIARViewController
    var modeChangeHandler: (() -> Void)?
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let myLocation = locationManager.lastLocation {
                    Annotation("나", coordinate: myLocation.coordinate) {
                        Marker()
                    }
                }
                
                if let peerLocationMessage = activityManager.locations.last {
                    Annotation(
                        peerLocationMessage.userName,
                        coordinate: .init(peerLocationMessage.location)
                    ) {
                        Marker(isPeer: true)
                    }
                }
            }
            
            Group {
                RadialGradientCover()
                
                VStack {
                    if let peerLocationMessage = activityManager.locations.last {
                        TitleLabel(pearName: peerLocationMessage.userName)
                    } else {
                        TitleLabel(pearName: "친구")
                    }
                    
                    Spacer()
                    
                    ShowDistanceViewButton {
                        modeChangeHandler?()
                    }
                }
                .padding(.vertical, 60)
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            locationManager.updateLocationHandler = { location in
                Task {
                    do {
                        try await activityManager.send(ShareLocationMessage(userName: "이거 나임", location: .init(location)))
                    } catch {
                        print(#fileID, #function, #line, "\(error)")
                    }
                }
            }
            locationManager.requestAuthorization()
            arViewController.pauseSession()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
            arViewController.startSession()
        }
        .onChange(of: locationManager.lastLocation) {
            guard let coordinate = locationManager.lastLocation?.coordinate else { return }
            
            withAnimation {
                cameraPosition = .region(
                    .init(
                        center: coordinate,
                        span: .init(
                            latitudeDelta: 0.02,
                            longitudeDelta: 0.02
                        )
                    )
                )
            }
        }
    }
}

extension MainLocationView {
    @ViewBuilder
    func Marker(isPeer: Bool = false) -> some View {
        ZStack {
            Circle()
                .fill(isPeer ? .green : .white)
                .frame(width: 40, height: 40)
            Circle()
                .fill(isPeer ? .white : .green)
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
    MainLocationView(
        activityManager: GroupActivityManager(),
        arViewController: NIARViewController()
    )
}
