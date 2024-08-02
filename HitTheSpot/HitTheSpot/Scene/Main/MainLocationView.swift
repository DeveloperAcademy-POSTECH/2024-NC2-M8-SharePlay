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
    @State private var workItem: DispatchWorkItem?
    let arUseCase: ARUseCase
    let modeChangeHandler: () -> Void
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                
                if let myLocation = myInfoUseCase.state.location {
                    Annotation("나", coordinate: .init(myLocation)) {
                        Marker()
                    }
                }
                
                if let peerInfo = peerInfoUseCase.state.profile,
                   let peerLocation = peerInfoUseCase.state.location
                {
                    Annotation(
                        peerInfo.name,
                        coordinate: .init(peerLocation)
                    ) {
                        Marker(isPeer: true)
                    }
                }
            }
            
            Group {
                RadialGradientCover()
                    .allowsHitTesting(false)
                
                VStack {
                    Group {
                        if let peerInfo = peerInfoUseCase.state.profile {
                            TitleLabel(pearName: peerInfo.name)
                        } else {
                            TitleLabel(pearName: "친구")
                        }
                    }
                    .allowsTightening(false)
                    
                    Spacer()
                    
                    ShowDistanceViewButton {
                        modeChangeHandler()
                    }
                }
                .padding(.vertical, 60)
            }
        }
        .onAppear {
//            locationManager.updateLocationHandler = { location in
//                Task {
//                    do {
//                        try await activityManager.send(ShareLocationMessage(userName: "이거 나임", location: .init(location)))
//                    } catch {
//                        print(#fileID, #function, #line, "\(error)")
//                    }
//                }
//            }
//            locationManager.requestAuthorization()
            arUseCase.effect(.stopSession)
        }
        .onDisappear {
//            locationManager.stopUpdatingLocation()
            arUseCase.effect(.startSession)
        }
        .onMapCameraChange(frequency: .continuous) {
            let peerLocation = peerInfoUseCase.state.location
            
            schedule(
                task: {
                    updateCameraPostion(for: [peerLocation?.toCLLocation()].compactMap { $0 })
                },
                after: .now() + 1
            )
        }
    }
}

extension MainLocationView {
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

extension MainLocationView {
    private func schedule(
        task: @escaping () -> Void,
        after: DispatchTime = .now() + 1
    ) {
        workItem?.cancel()
        let item = DispatchWorkItem { task() }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: after, execute: item)
    }
    
    private func updateCameraPostion(for locations: [CLLocation] = []) {
        guard let myLocation = myInfoUseCase.state.location else { return }
        
        guard !locations.isEmpty else {
            let camPostion = MapCameraPosition.region(
                .init(
                    center: .init(myLocation),
                    span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02) // 기본값으로 0.02로 설정
                )
            )
            
            moveCamera(to: camPostion)
            return
        }
        
        guard let maxDistance = locations.map({ $0.distance(from: myLocation.toCLLocation()) }).max() else { return }
        
        let span = MKCoordinateSpan(
            latitudeDelta: maxDistance * 2 * 1.2, // 기본값으로 1.2 만큼 확장되도록 설정
            longitudeDelta: maxDistance * 2 * 1.2
        )
        
        moveCamera(to: .region(.init(center: .init(myLocation), span: span)))
    }
    
    private func moveCamera(to position: MapCameraPosition) {
        withAnimation {
            cameraPosition = .userLocation(followsHeading: true, fallback: position)
        }
    }
}

#Preview {
    MainLocationView(myInfoUseCase: .init(activityManager: .init(), niManager: .init(), locationManager: .init()), peerInfoUseCase: .init(activityManager: .init(), niManager: .init()), arUseCase: .init(niManager: .init(), arManager: .init()), modeChangeHandler: {})
}
