//
//  NIStatus.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import Foundation

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
