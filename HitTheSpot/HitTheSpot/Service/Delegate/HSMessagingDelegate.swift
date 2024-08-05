//
//  HSMessagingDelegate.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import Foundation

// MARK: - Messaging
protocol HSMessagingDelegate: AnyObject {
    func receive(_ message: HSMessage)
}
