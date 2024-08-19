//
//  MeasurementQualityEstimator.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import Foundation
import NearbyInteraction

class MeasurementQualityEstimator {
    /// 허용되는 타임 윈도우
    let freshnessWindow = TimeInterval(floatLiteral: 2.0)
    /// 최소 샘플 수
    let minSamples: Int = ThreshHold.minSamples
    /// 최대 거리, 미터 단위
    let maxDistance: Float = ThreshHold.maxDistance
    /// 최소 거리, 미터 단위
    let closeDistance: Float = ThreshHold.nearByDistance
    
    // A buffer to hold the individual quality measurements.
    private var measurements: [TimedNIObject] = []
    
    // An enumeration that defines levels of peer quality.
    enum MeasurementQuality {
        case unknown
        case good
        case close
    }
    
    struct TimedNIObject {
        let time: TimeInterval
        let distance: Float
    }
    
    func estimateQuality(update: NINearbyObject?) -> MeasurementQuality {
        let timeNow = NSDate().timeIntervalSinceReferenceDate
        let validTimestamp = timeNow - freshnessWindow
        
        if let distance = update?.distance {
            if let lastMeasureMent = measurements.last {
                if lastMeasureMent.distance != distance {
                    measurements.append(TimedNIObject(time: timeNow, distance: distance))
                }
            } else {
                measurements.append(TimedNIObject(time: timeNow, distance: distance))
            }
        }
        
        measurements.removeAll { $0.time < validTimestamp }
        
        if measurements.count > minSamples,
           let lastDistance = measurements.last?.distance
        {
            if lastDistance <= closeDistance { return .close }
            return lastDistance < maxDistance ? .good : .unknown
        }
        return .unknown
    }
}
