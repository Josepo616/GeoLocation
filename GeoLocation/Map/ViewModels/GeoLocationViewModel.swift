//
//  LocationManager.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import Combine
import CoreLocation
import Foundation

class GeoLocationViewModel: NSObject, ObservableObject,
    CLLocationManagerDelegate
{

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    var cancellables = Set<AnyCancellable>()


    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        @unknown default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            return
        }

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print(
            "[LocationManager] Error getting location: \(error.localizedDescription)"
        )
    }

    func reverseGeocode(_ location: CLLocation) -> AnyPublisher<
        CLPlacemark, Error
    > {
        geocoder
            .reverseGeocodePublisher(for: location)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getPlaceName(from location: CLLocation) -> AnyPublisher<String, Error> {
        return geocoder
            .reverseGeocodePublisher(for: location)
            .map { placemark in
                let placeName = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                return placeName
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
