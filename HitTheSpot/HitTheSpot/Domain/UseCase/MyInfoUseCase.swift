//
//  UserLocationUseCase.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/15/24.
//

import SwiftUI
import CoreLocation
import MapKit
import NearbyInteraction

@Observable
class MyInfoUseCase {
    
    enum Action {
        case startMonitorLocation
        case stopMonitorLocation
        case updateProfile(_ profile: HSUserProfile)
        case didGPSUpdated(location: HSLocation)
        case didPeerJoined
        
        case sendProfile(profile: HSUserProfile)
        case sendToken(token: NIDiscoveryToken)
        case sendLocation(location: HSLocation)
        case sendError(error: Error)
        case saveError
        case noProfileError
    }
    
    struct State {
        var profile: HSUserProfile? = nil
        var location: HSLocation? = nil
        var token: NIDiscoveryToken? = nil
    }
    
    private let activityManager: HSGroupActivityManager
    private let locationManager: HSLocationManager
    private(set) var state: State
    
    init(
        activityManager: HSGroupActivityManager,
        locationManager: HSLocationManager
    ) {
        if let savedProfile = UserDefaults.standard.data(forKey: "profile"),
            let profile = try? JSONDecoder().decode(HSUserProfile.self, from: savedProfile) {
            self.state = .init(profile: profile)
        } else {
            self.state = .init()
        }
        self.activityManager = activityManager
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }
    
    public func effect(_ action: Action) {
        switch action {
        case .startMonitorLocation:
            locationManager.startUpdating()
        case .stopMonitorLocation:
            locationManager.stopUpdating()
        case .updateProfile(let profile):
            save(profile)
            state.profile = profile
        case .didGPSUpdated(let location):
            state.location = location
        case .didPeerJoined:
            guard let profile = state.profile else {
                effect(.noProfileError)
                return
            }
            effect(.sendProfile(profile: profile))
        case .sendProfile(let profile):
            Task {
                do {
                    try await activityManager.send(.profile(profile))
                } catch {
                    effect(.sendError(error: error))
                }
            }
        case .sendToken(let token):
            Task {
                do {
                    try await activityManager.send(.token(encode(token)))
                } catch {
                    effect(.sendError(error: error))
                }
            }
        case .sendLocation(let location):
            Task {
                do {
                    try await activityManager.send(.location(location))
                } catch {
                    effect(.sendError(error: error))
                }
            }
        case .sendError: 
            break
        case .saveError:
            HSLog(from: "MyInfoUseCase", with: "Profile Save Error")
        case .noProfileError:
            break
        }
    }
    
    private func encode<T: NSObject & NSSecureCoding>(_ object: T) throws -> Data {
        guard let encodedData = try? NSKeyedArchiver.archivedData(
            withRootObject: object,
            requiringSecureCoding: true
        ) else {
            throw HSMessagingError.encodingError
        }
        
        return encodedData
    }
    
    private func save(_ profile: HSUserProfile) {        
        guard let compressedImgData = compressImage(imgData: profile.imgData, to: 1024),
              let encodedProfile = try? JSONEncoder().encode(HSUserProfile(name: profile.name, imgData: compressedImgData))
        else {
            effect(.saveError)
            return
        }
        
        UserDefaults.standard.set(encodedProfile, forKey: "profile")
    }
        
    private func compressImage(imgData: Data?, to maxSizeInBytes: Int) -> Data? {
        guard let imgData,
              let uiImage = UIImage(data: imgData) 
        else { return nil }
        
        var compression: CGFloat = 1.0
        var compressedData = uiImage.jpegData(compressionQuality: compression)

        while let data = compressedData,
              data.count > maxSizeInBytes && compression > 0 {
            compression -= 0.1
            compressedData = uiImage.jpegData(compressionQuality: compression)
        }

        return compressedData
    }
}

extension MyInfoUseCase: HSLocationDelegate {
    func didLocationUpdate(_ location: HSLocation) {
        effect(.didGPSUpdated(location: location))
    }
}
