//
//  MainLocationView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainLocationView: View {
    var modeChangeHandler: (() -> Void)?
    
    var body: some View {
        ShowDistanceViewButton {
            modeChangeHandler?()
        }
    }
}

extension MainLocationView {
    @ViewBuilder
    func ShowDistanceViewButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "arrow.up.circle")
                Text("거리 보기")
            }
            .foregroundStyle(.black)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .background(.white)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    MainLocationView()
        .preferredColorScheme(.dark)
}
