//
//  ContentView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/16/24.
//

import SwiftUI
import NearbyInteraction

enum NIStatus {
    case notSupported
    case precise
    case extended
    
    var description: String {
        switch self {
        case .notSupported:
            "해당 기기에서는 NI기능을 지원하지 않습니다."
        case .precise:
            "해당 기기에서는 U1칩 기반 NI 기능을 지원합니다."
        case .extended:
            "해당 기기에서는 U2칩 기반 NI 기능을 지원합니다."
        }
    }
}

struct ContentView: View {
    var isSupportU1: Bool { NISession.deviceCapabilities.supportsPreciseDistanceMeasurement }
    var isSupportU2: Bool { NISession.deviceCapabilities.supportsExtendedDistanceMeasurement }
    
    var body: some View {
        if #available(iOS 17.0, watchOS 10.0, *), isSupportU2 {
            NICameraAssistanceView(niStatus: .extended)
        } else if isSupportU1 {
            NICameraAssistanceView(niStatus: .precise)
        } else {
            NINotSupportedDeviceView()
        }
    }
}

#Preview {
    ContentView()
}
