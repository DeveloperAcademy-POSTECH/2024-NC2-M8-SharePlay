//
//  VibrationManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 8/5/24.
//

import Foundation
import CoreHaptics

class VibrationManager {
    typealias HapticType = CHHapticEvent.EventType
    
    static let shared = VibrationManager()
    
    private let hapticEngine: CHHapticEngine
    
    /// 엔진이 패턴 가지고 만드는 플레이어
    private var hapticAdvancedPlayer: CHHapticAdvancedPatternPlayer? = nil
    
    private init?() {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        
        guard hapticCapability.supportsHaptics else {
            print("Haptic engine Creation Error: Not Support")
            return nil
        }
        
        do {
            hapticEngine = try CHHapticEngine()
        } catch let error {
            print("Haptic engine Creation Error: \(error)")
            return nil
        }
    }

    func stopHaptic() {
        do {
            try hapticAdvancedPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stopHaptic: \(error)")
        }
    }
    
    func playHaptic(haptic: CustomHaptic) {
        do {
            try hapticAdvancedPlayer?.stop(atTime: 0)
            
            let pattern = try makePattern(haptic: haptic)
            
            hapticAdvancedPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            hapticAdvancedPlayer?.loopEnabled = true
            hapticAdvancedPlayer?.playbackRate = 1.0
            
            try hapticEngine.start()
            try hapticAdvancedPlayer?.start(atTime: 0)
            
        } catch {
            print("Failed to playHaptic: \(error)")
        }
    }
    
    private func makePattern(haptic: CustomHaptic) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        var relativeTime = 0.0

        for (index, duration) in haptic.durations.enumerated() {
            let power = haptic.powers[index]
            let type = haptic.types[index]
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: power)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            
            let event = CHHapticEvent(
                eventType: type,
                parameters: [intensity, sharpness],
                relativeTime: relativeTime,
                duration: duration
            )
            
            events.append(event)
            
            relativeTime += duration
        }

        return try CHHapticPattern(events: events, parameters: [])
    }
}

extension VibrationManager {
    struct CustomHaptic {
        var types: [HapticType]
        var durations: [Double]
        var powers: [Float]
        
        static var sample: CustomHaptic {
            .init(
                types: [
                    .hapticTransient,
                    .hapticTransient,
                    .hapticTransient,
                    .hapticContinuous,
                    .hapticContinuous
                ],
                durations: [0.3, 0.3, 0.3, 0.7, 0.4],
                powers: [0.3, 0.5, 0.7, 0.8, 0.3]
            )
        }
    }
}
