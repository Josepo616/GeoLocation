//
//  LocationManager.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import Foundation
import CoreLocation
import Combine

final class GeoLocationViewModel: ObservableObject {
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: APIError?
    @Published var showFailed = false
    @Published private(set) var isConnected: Bool = true


    private let locationService = LocationService()
    private let networkMonitor = NetworkMonitorService()
    private let geocoder = CLGeocoder()
    var cancellables = Set<AnyCancellable>()

    init() {
        bindServices()
        Timer
            .publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.locationService.requestLocation()
            }
            .store(in: &cancellables)
    }

    private func bindServices() {
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] location in
                self?.userLocation = location.coordinate
            })
            .store(in: &cancellables)

        locationService.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
            }
            .store(in: &cancellables)

        locationService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.locationError = error
                self?.showFailed = true
            }
            .store(in: &cancellables)

        networkMonitor.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnected = connected
                if !connected {
                    self?.locationError = .noConnection
                } else if self?.locationError == .noConnection {
                    self?.locationError = nil
                }
            }
            .store(in: &cancellables)
    }

    func getPlaceName(from location: CLLocation) -> AnyPublisher<String, APIError> {
        guard isConnected else {
            return Fail(error: .noConnection).eraseToAnyPublisher()
        }

        return Future<String, APIError> { [weak self] promise in
            self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(LocationErrorMapper.map(error)))
                    print(promise(.failure(LocationErrorMapper.map(error))))
                    return
                }

                guard let placemark = placemarks?.first,
                      let name = placemark.name,
                      let locality = placemark.locality,
                      let administrativeArea = placemark.administrativeArea,
                      let country = placemark.country else {
                    promise(.failure(.geocodingFailed))
                    return
                }

                let fullName = [name, locality, administrativeArea, country].joined(separator: ", ")
                promise(.success(fullName))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
