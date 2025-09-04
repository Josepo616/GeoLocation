//
//  LocationService.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, APIError>()
    private let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let errorSubject = PassthroughSubject<APIError, Never>()

    var locationPublisher: AnyPublisher<CLLocation, APIError> {
        locationSubject.eraseToAnyPublisher()
    }

    var authorizationPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationSubject.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<APIError, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            errorSubject.send(.locationPermissionDenied)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            errorSubject.send(.locationUnavailable)
            return
        }
        locationSubject.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorSubject.send(LocationErrorMapper.map(error))
    }
}
