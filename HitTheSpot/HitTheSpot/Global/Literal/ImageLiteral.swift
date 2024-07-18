//
//  ImageLiteral.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/2/24.
//

import SwiftUI

enum Literal {
    enum HSImage {
        static let title = Image("Title")
        static let titleWithLogo = Image("TitleWithLogo")
        static let mainHomeBg = Image("MainHomeBg")
        static let arrow = Image("DirectionArrow")
    }
    
    enum Icon {
        static let xmark = Image(systemName: "xmark.circle")
        
        static let sharePlay = Image(systemName: "shareplay")
        static let location = Image(systemName: "smallcircle.filled.circle")
        static let distance = Image(systemName: "arrow.up.circle")
    }
}
