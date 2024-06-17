//
//  NIUnsupportedDeviceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/17/24.
//

import SwiftUI

struct NINotSupportedDeviceView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                    .resizable()
                .frame(width: 50, height: 50, alignment: .center)
            
            Text("Unsupported Device")
                .bold()
        }
        .padding()
        .foregroundColor(.red)
    }
}

#Preview {
    NINotSupportedDeviceView()
}
