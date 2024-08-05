//
//  HitTheSpotApp.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/16/24.
//

import SwiftUI
import NearbyInteraction

@main
struct HitTheSpotApp: App {
    private let sharePlayUseCase: SharePlayUseCase
    private let myInfoUseCase: MyInfoUseCase
    private let peerInfoUseCase: PeerInfoUseCase
    private let arUseCase: ARUseCase
    
    var isSupportU2: Bool { NISession.deviceCapabilities.supportsExtendedDistanceMeasurement }
    
    init() {
        let activityManager = HSGroupActivityManager()
        let niManager = NISessionManager()
        
        sharePlayUseCase = .init(manager: activityManager)
        
        myInfoUseCase = .init(
            activityManager: activityManager, 
            niManager: niManager,
            locationManager: HSLocationManager()
        )
        
        peerInfoUseCase = .init(
            activityManager: activityManager,
            niManager: niManager
        )
        
        arUseCase = .init(
            niManager: niManager,
            arManager: HSARManager()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, watchOS 10.0, *), isSupportU2 {
                // iPhone 15, iOS 17 이상
                ContentView(
                    sharePlayUseCase: sharePlayUseCase,
                    myInfoUseCase: myInfoUseCase,
                    peerInfoUseCase: peerInfoUseCase,
                    arUseCase: arUseCase
                )
            } else {
                // 지원 대상 아님
                NINotSupportedDeviceView()
            }
        }
    }
}
