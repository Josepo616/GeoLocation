//
//  GeoLocationManager.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import Combine
import CoreLocation
import Foundation

/// ViewModel responsible for managing location data, connectivity, and user's visited places.
final class GeoLocationViewModel: ObservableObject {

    @Published private(set) var isConnected: Bool = true
    @Published private(set) var visitedPlaces: [VisitedPlaceModel] = []
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationError: APIError?
    @Published var showFailed = false
    @Published var stringLatestLocation: String = ""
    @Published var stringCurrentLocation: String = ""
    @Published var stringDistanceChanged: String = ""
    @Published var droppedPins: [CLLocationCoordinate2D] = []
    private let locationService = LocationService()
    private let networkMonitor = NetworkMonitorService()
    private let geocoder = CLGeocoder()
    private var lastFetchedLocation: CLLocation?
    private var initialLocation: CLLocation?
    var cancellables = Set<AnyCancellable>()

    init() {
        bindServices()
    }

    // MARK: - Bindings
    /// Binds the location, authorization, error, and network monitors to update the view model's properties.
    /// This ensures the ViewModel reacts to location updates, permission changes, errors, and network status.
    private func bindServices() {
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    print("[LocationPublisher] completion: \(completion)")
                },
                receiveValue: { [weak self] location in
                    self?.handleNewLocation(location)
                }
            )
            .store(in: &cancellables)

        locationService.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways
                {
                    self?.startLocationUpdates()
                } else {
                    self?.locationError = .locationPermissionDenied
                }
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

    // MARK: - Location funcitons
    /// Starts location updates by periodically requesting the user's location every 5 seconds.
    private func startLocationUpdates() {
        Timer
            .publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.locationService.requestLocation()
            }
            .store(in: &cancellables)
    }

    /// Handles updates when a new location is fetched.
    /// It checks for significant location changes and updates the user's location, place name, and distance.
    private func handleNewLocation(_ location: CLLocation) {
        userLocation = location.coordinate
        if initialLocation == nil {
            initialLocation = location
        }
        guard let last = lastFetchedLocation else {
            lastFetchedLocation = location
            getPlaceName(from: location)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.locationError = error
                    }
                } receiveValue: { [weak self] placeName in
                    guard let self = self else { return }
                    self.stringLatestLocation = placeName
                    self.stringCurrentLocation = placeName
                    self.stringDistanceChanged = "0 m"
                    let newPlace = VisitedPlaceModel(
                        name: placeName,
                        location: location.coordinate,
                        date: Date(),
                        timestamp: Date()
                    )
                    self.visitedPlaces.append(newPlace)
                }
                .store(in: &cancellables)
            return
        }
        
        guard let initialLocation = initialLocation else { return }
        
        let distanceToshow = location.distance(from: initialLocation)
        stringDistanceChanged = String(format: "%.2f m", distanceToshow)
        let distance = location.distance(from: last)
        guard distance >= 20 else {
            return
        }

        getPlaceName(from: location)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.locationError = error
                }
            } receiveValue: { [weak self] placeName in
                guard let self = self else { return }

                if self.stringLatestLocation.isEmpty
                    || self.stringLatestLocation != self.stringCurrentLocation
                {
                    self.stringLatestLocation = self.stringCurrentLocation
                }
                self.stringCurrentLocation = placeName

                let newPlace = VisitedPlaceModel(
                    name: placeName,
                    location: location.coordinate,
                    date: Date(),
                    timestamp: Date()
                )

                if !self.visitedPlaces.contains(where: {
                    $0.isDuplicate(of: newPlace)
                }) {
                    self.visitedPlaces.append(newPlace)
                }
                self.droppedPins.append(
                    userLocation
                        ?? CLLocationCoordinate2D(
                            latitude: 48.8584,
                            longitude: 2.3522
                        )
                )
                self.lastFetchedLocation = location
            }
            .store(in: &cancellables)
    }

    /// Fetches the place name for a given location using reverse geocoding.
    /// If the user is offline, it returns a no connection error.
    func getPlaceName(from location: CLLocation) -> AnyPublisher<
        String, APIError
    > {
        guard isConnected else {
            return Fail(error: .noConnection).eraseToAnyPublisher()
        }

        return Future<String, APIError> { [weak self] promise in

            self?.geocoder.reverseGeocodeLocation(location) {
                placemarks,
                error in
                if let error = error {
                    let mappedError = LocationErrorMapper.map(error)
                    promise(.failure(mappedError))
                    return
                }

                guard let placemark = placemarks?.first,
                    let name = placemark.name,
                    let locality = placemark.locality,
                    let administrativeArea = placemark.administrativeArea,
                    let country = placemark.country
                else {
                    promise(.failure(.geocodingFailed))
                    return
                }

                let fullName = [name, locality, administrativeArea, country]
                    .joined(separator: ", ")
                promise(.success(fullName))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
