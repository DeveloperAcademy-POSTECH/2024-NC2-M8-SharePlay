//
//  HSMessagingError.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/18/24.
//

import Foundation

enum HSMessagingError: LocalizedError {
    case encodingError
    case decodingError
    case sendError
    
    public var errorDescription: String? {
        switch self {
        case .encodingError:
            "인코딩 에러"
        case .decodingError:
            "디코딩 에러"
        case .sendError:
            "전송 에러"
        }
    }
}
