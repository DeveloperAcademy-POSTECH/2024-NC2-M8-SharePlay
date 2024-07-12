//
//  LocationManager.swift
//  HitTheSpot
//
//  Created by 남유성 on 6/19/24.
//

import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject {
    var lastLocation: CLLocation?
    
    @ObservationIgnored var updateLocationHandler: ((CLLocation) -> Void)?
    @ObservationIgnored private let _locationManager = CLLocationManager()
    
    override init() {
        super.init()
        _locationManager.delegate = self
    }
}

extension LocationManager {
    /// 위치 권한 요청 함수
    ///
    /// 사용자에게 위치 권한을 요청하고, 만약 권한이 있는 경우 Location 업데이트를 시작합니다.
    public func requestAuthorization() {
        switch _locationManager.authorizationStatus {
            
        // MARK: - 사용자가 위치 권한을 설정하지 않은 상태
        case .notDetermined:
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager.requestWhenInUseAuthorization()
            log("사용자의 위치 권한을 요청합니다.")
        
        // MARK: - 사용자가 위치 권한을 거부, 제한한 상태
        case .denied, .restricted:
            _locationManager.requestWhenInUseAuthorization()
            _locationManager.stopUpdatingLocation()
            log("사용자의 위치 업데이트를 중지합니다.")
            
        // MARK: - 사용자가 위치 권한을 항상/사용 중일 때 허용한 상태
        case .authorizedAlways, .authorizedWhenInUse:
            
            // 사용자 위치 업데이트 활성화
            _locationManager.startUpdatingLocation()
            log("사용자의 위치 업데이트를 시작합니다.")
            
        default:
            break
        }
    }
    
    public func stopUpdatingLocation() {
        _locationManager.stopUpdatingLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    /// 위치 정보가 업데이트 되었을 때 실행
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else { return }
    
        lastLocation = latestLocation
        updateLocationHandler?(latestLocation)
    }
    
    /// 위치 권한이 변경되었을 때 실행
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        log("권한이 [\(manager.authorizationStatus)]로 변경되었습니다.")
        requestAuthorization()
    }
}

extension LocationManager {
    private func log(_ message: String) {
        HSLog(from: "\(Self.self)", with: message)
    }
}

