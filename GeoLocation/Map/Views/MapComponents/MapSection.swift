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
    @State var showInfo: Bool = false
    @State private var didDropInitialPin = false
    @State private var mensaje: String = ""
    private let geocoder = CLGeocoder()
    var locationViewModel: GeoLocationViewModel


    var body: some View {
        VStack {
            if let userLocation = locationViewModel.userLocation {
                TapMapView(
                    droppedPins: $droppedPins,
                    showInfo: $showInfo,
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
                .alert("Location", isPresented: $showInfo, presenting: mensaje)
                { _ in
                    Button("OK") { showInfo = false }
                    Button("Try Again") { showInfo = false }
                } message: { _ in
                    Text(mensaje)
                        .foregroundColor(.red)
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
                if case .failure(let error) = completion {
                    print("[Geocoder] Error: \(error.localizedDescription)")
                }
            } receiveValue: { placeName in
                mensaje = placeName
            }
            .store(in: &locationViewModel.cancellables)

    }
}
