//
//  MainNearbyView.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/18/24.
//

import SwiftUI

struct MainNearbyView: View {
    @State private var peerName: String = "라뮤"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Title()
                    .padding(.top, 80)
                
                Spacer()
                
                Literal.HTSImage.title
                    .resizable()
                    .scaledToFit()
                    .opacity(0.2)
            }
            .padding(.horizontal, 24)
            
            LottieView(filename: "NearbyEffect")
        }
    }
}

extension MainNearbyView {
    @ViewBuilder
    func Title() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(peerName)와 가까워졌어요")
            HStack {
                Text("주변에서")
                Text("\(peerName)를 찾아보세요!")
                    .foregroundStyle(.accent)
                
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .font(.pretendard24)
    }
}

#Preview {
    MainNearbyView()
        .preferredColorScheme(.dark)
}
