//
//  MainDistanceView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainDistanceView: View {
    var modeChangeHandler: (() -> Void)?
    
    var body: some View {
        ShowLocationViewButton {
            modeChangeHandler?()
        }
    }
}

extension MainDistanceView {
    @ViewBuilder
    func ShowLocationViewButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Literal.Icon.location
                Text("위치 보기")
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
    MainDistanceView()
        .preferredColorScheme(.dark)
}
