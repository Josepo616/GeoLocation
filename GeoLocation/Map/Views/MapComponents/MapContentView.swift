import Combine
import MapKit
//
//  MapContentView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//
import SwiftUI

struct MapContentView: View {

    @Binding var stringLatestLocation: String
    @Binding var stringCurrentLocation: String
    @Binding var stringDistanceChanged: String
    @State private var droppedPins: [CLLocationCoordinate2D] = []
    @State private var mapView = MKMapView()
    @State private var cancellables: Set<AnyCancellable> = []
    var locationViewModel: GeoLocationViewModel

    var body: some View {
        VStack {
            MapSection(
                mapView: $mapView,
                droppedPins: $droppedPins,
                error: locationViewModel.locationError,
                locationViewModel: locationViewModel

            )

            LocationFormView(
                stringLatestLocation: $stringLatestLocation,
                stringCurrentLocation: $stringCurrentLocation,
                stringDistanceChanged: $stringDistanceChanged
            )

            TrackingControlsView()
                .padding()
        }
        .onReceive(locationViewModel.$userLocation.compactMap { $0 }) {
            (location: CLLocationCoordinate2D) in
            let clLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )

            locationViewModel.getPlaceName(from: clLocation)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("[Geocoder] Error: \(error.localizedDescription)")
                    }
                } receiveValue: { placeName in
                    if stringLatestLocation.isEmpty {
                        stringLatestLocation = placeName
                    }
                    stringCurrentLocation = placeName
                }
                .store(in: &cancellables)

        }
    }
}
