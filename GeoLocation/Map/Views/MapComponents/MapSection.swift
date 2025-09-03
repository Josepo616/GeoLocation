//
//  MapSection.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import MapKit
import SwiftUI

struct MapSection: View {

    @Binding var mapView: MKMapView
    @Binding var droppedPins: [CLLocationCoordinate2D]
    @State var showInfo = false
    @State var showFailed = false
    @State private var didDropInitialPin = false
    @State private var placeFormated = ""
    @State private var errorMessage = ""
    private let geocoder = CLGeocoder()
    var error: APIError?
    var locationViewModel: GeoLocationViewModel


    var body: some View {
        VStack {
            if let userLocation = locationViewModel.userLocation {
                TapMapView(
                    droppedPins: $droppedPins,
                    initialCenter: userLocation
                )
                .frame(maxWidth: .infinity, maxHeight: 300, alignment: .top)
                .cornerRadius(30)
                .onAppear {
                    if !didDropInitialPin {
                        droppedPins.append(userLocation)
                        didDropInitialPin = true
                    }
                }
                .onReceive(TapMapView.coordinatePublisher) { coordinate in
                    handleMapTap(at: coordinate)
                }
                .alert("Location", isPresented: $showInfo, presenting: placeFormated)
                { _ in
                    Button("OK") { showInfo = false }
                } message: { _ in

                    Text(placeFormated)
                        .foregroundColor(Color.red)
                }
                .alert("Error", isPresented: $showFailed, presenting: error)
                { _ in
                    Button("OK") { showFailed = false }
                } message: { error in

                    Text(error.errorDescription!)
                        .foregroundColor(Color.red)
                }
            } else {
                ProgressView("Getting location...")
                    .frame(height: 300)
            }
        }
    }

    // MARK: - Helpers

    private func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        let clLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        locationViewModel.getPlaceName(from: clLocation)
            .sink { completion in
                print("get place if not fail")
                if case .failure(let error) = completion {
                    print("[Geocoder] Error: \(error.localizedDescription)")
                    showFailed = true
                }
            } receiveValue: { placeName in
                placeFormated = placeName
                showInfo = true
            }
            .store(in: &locationViewModel.cancellables)
    }
}
