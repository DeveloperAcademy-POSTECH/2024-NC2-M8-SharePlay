//
//  ProfileSettingView.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/20/24.
//

import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @Environment(\.dismiss) var dismiss
    
    let myProfileUseCase: MyInfoUseCase
    @State private var name: String
    @State private var imgData: Data?
    @State private var nameState: NameState
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var description: String {
        switch name.count {
        case 1:
            return "2자 이상 입력해주세요."
        case 0, 2...10:
            return " "
        default:
            return "10자 이내로 입력해주세요."
        }
    }
    
    init(myProfileUseCase: MyInfoUseCase) {
        self.myProfileUseCase = myProfileUseCase
        let profile = myProfileUseCase.state.profile
        self.name = profile?.name ?? ""
        self.imgData = profile?.imgData
        self.nameState = (profile != nil) ? .valid : .none
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                VStack(spacing: 82) {
                    ProfilePicker()
                    
                    NameTextField()
                }
                .padding(.top, 82)
                
                Spacer()
                
                VStack(spacing: 16) {
                    CompleteButton {
                        myProfileUseCase.effect(
                            .updateProfile(.init(name: name, imgData: imgData))
                        )
                        dismiss()
                    }
                    
                    LaterButton {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .onChange(of: name) { _, newValue in
            switch name.count {
            case 0:
                nameState = .none
            case 2...10:
                nameState = .valid
            default:
                nameState = .inValid
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imgData = data
                }
            }
        }
    }
}

extension ProfileSettingView {
    enum NameState {
        case valid
        case inValid
        case none
        
        var color: Color {
            switch self {
            case .valid: .accent
            case .inValid: .red1
            case .none: .white
            }
        }
    }
}

extension ProfileSettingView {
    @ViewBuilder
    func ProfilePicker() -> some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .any(of: [.images, .not(.livePhotos)])
        ) {
            ZStack(alignment: .bottomTrailing) {
                if let imgData,
                   let uiImage = UIImage(data: imgData)
                {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Literal.HSImage.profile
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundStyle(.gray1)
                    
                    Literal.Icon.photo
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .offset(x: 0.5, y: 0.5)
                }
            }
        }
    }
    
    @ViewBuilder
    func NameTextField() -> some View {
        VStack(alignment: .leading) {
            Text("닉네임을 입력하세요")
                .font(.pretendard20)
            
            TextField(
                "",
                text: $name,
                prompt: Text("2-10자 이하의 한글, 영어, 숫자")
                        .foregroundStyle(.gray1)
            )
                .frame(height: 54)
                .padding(.horizontal, 26)
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(nameState.color, lineWidth: 1)
                        .frame(height: 54)
                }
            
            Text(description)
                .foregroundStyle(nameState.color)
                .padding(.leading, 26)
        }
        .foregroundStyle(.white)
    }
    
    @ViewBuilder
    func CompleteButton(action: @escaping () -> Void) -> some View {
        HSButton(
            isActive: .init(
                get: { nameState == .valid },
                set: { _ in }
            ),
            text: "완료"
        ) {
            action()
        }
    }
    
    @ViewBuilder
    func LaterButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text("나중에 하기")
                .font(.pretendard16)
                .foregroundStyle(.white)
                .underline()
        }
    }
}

#Preview {
    ProfileSettingView(myProfileUseCase: .init(activityManager: .init(), locationManager: .init()))
}
