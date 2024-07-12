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
    var isSupportU2: Bool { NISession.deviceCapabilities.supportsExtendedDistanceMeasurement }
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, watchOS 10.0, *), isSupportU2 {
                // iPhone 15, iOS 17 이상
                ContentView(niStatus: .extended)
            } else {
                // 지원 대상 아님
                NINotSupportedDeviceView()
            }
        }
    }
}
