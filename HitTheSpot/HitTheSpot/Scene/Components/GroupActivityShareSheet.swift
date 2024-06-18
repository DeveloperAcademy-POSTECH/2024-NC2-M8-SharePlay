//
//  GroupActivityShareSheet.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI
import UIKit
import GroupActivities

struct GroupActivityShareSheet<Activity: GroupActivity>: UIViewControllerRepresentable {
    let preparationHandler: () async throws -> Activity

    func makeUIViewController(context: Context) -> UIViewController {
        GroupActivitySharingController(preparationHandler: preparationHandler)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
