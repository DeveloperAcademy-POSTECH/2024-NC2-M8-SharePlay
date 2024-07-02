//
//  NIUnsupportedDeviceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NINotSupportedDeviceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Literal.Icon.xmark
                .resizable()
                .frame(width: 50, height: 50, alignment: .center)
            
            Text("iPhone 15 이상의 기기만 지원합니다.")
                .bold()
        }
        .padding()
        .foregroundColor(.red)
    }
}

#Preview {
    NINotSupportedDeviceView()
}
