//
//  HSButton.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/20/24.
//

import SwiftUI

struct HSButton: View {
    @Binding var isActive: Bool
    
    let text: String
    var icon: Image?
    let action: () -> Void
    
    init(
        isActive: Binding<Bool> = .constant(true),
        text: String,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self._isActive = isActive
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 50)
                .frame(height: 58)
                .foregroundColor(isActive ? .accentColor : .gray1)
                .overlay(
                    Label(
                        title: { Text(text) },
                        icon: { icon }
                    )
                    .font(.pretendard20)
                    .foregroundColor(isActive ? .black : .white)
                )
        }
        .disabled(!isActive)
    }
}

#Preview {
    HSButton(
        text: "SharePlay로 친구 찾기",
        icon: Literal.Icon.sharePlay
    ) {}
}
