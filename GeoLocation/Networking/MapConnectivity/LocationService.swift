//
//  LocationService.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import Foundation
import CoreLocation
import Combine

/// A service class responsible for managing location updates, permissions,
/// and exposing publishers for location-related events using Combine.
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

    /// Initializes the CLLocationManager and sets up desired accuracy and permissions.
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

    /// Called when the user changes the app's location authorization status.
    /// Starts location updates if authorized, or sends error if denied.
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

    /// Called when the CLLocationManager receives new location data.
    /// Emits the most recent location or an error if none found.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            errorSubject.send(.locationUnavailable)
            return
        }
        locationSubject.send(location)
    }

    /// Called when the CLLocationManager encounters an error.
    /// Maps and forwards the error through the Combine errorPublisher.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorSubject.send(LocationErrorMapper.map(error))
    }
}
