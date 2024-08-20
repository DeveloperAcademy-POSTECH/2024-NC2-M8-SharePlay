//
//  LocationManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 7/13/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    private let manager: CLLocationManager
    private var location: CLLocation?
    private var isUpdating: Bool = false
    private var curLocationCompletion: ((CLLocation?) -> Void)?
    
    weak var delegate: HSLocationDelegate?
    
    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
}

extension LocationManager {
    public func startUpdating() {
        switch manager.authorizationStatus {
        case .notDetermined:
            requestAuthorization()
            
        case .denied, .restricted:
            requestAuthorization()
            stopUpdating()
            
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
            
        @unknown default:
            requestAuthorization()
        }
    }
    
    public func stopUpdating() {
        isUpdating = false
        location = nil
        manager.stopUpdatingLocation()
        log("사용자의 위치 업데이트를 중지합니다.")
    }
    
    public func loadCurLocation(_ completion: @escaping (CLLocation?) -> Void) {
        if isUpdating {
            completion(location)
        } else {
            curLocationCompletion = { [weak self] location in
                completion(location)
                self?.stopUpdating()
            }
            startUpdating()
        }
    }
    
    private func requestAuthorization() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        log("사용자의 위치 권한을 요청합니다.")
    }
    
    private func startUpdatingLocation() {
        isUpdating = true
        manager.startUpdatingLocation()
        log("사용자의 위치 업데이트를 시작합니다.")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// 위치 정보가 업데이트 되었을 때 실행
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else { return }
    
        location = latestLocation
        delegate?.didLocationUpdate(.init(latestLocation))
        curLocationCompletion?(latestLocation)
    }
    
    /// 위치 권한이 변경되었을 때 실행
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        log("권한이 [\(manager.authorizationStatus.description)]로 변경되었습니다.")
        
        switch manager.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            requestAuthorization()
        default:
            break
        }
    }
}

// MARK: - Log 관련
extension LocationManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}
