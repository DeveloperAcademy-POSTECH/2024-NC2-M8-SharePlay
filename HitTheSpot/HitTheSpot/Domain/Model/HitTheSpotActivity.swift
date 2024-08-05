//
//  HitTheSpotActivity.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/14/24.
//

import UIKit
import GroupActivities

struct HitTheSpotActivity: GroupActivity {
    static let activityIdentifier = Constant.activityIdentifier

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Hit the Spot!"
        metadata.subtitle = "친구 찾기 어려울 땐, 여기로 모여!"
        metadata.previewImage = UIImage(named: "SharePlay")?.cgImage
        metadata.type = .generic
        return metadata
    }
}
