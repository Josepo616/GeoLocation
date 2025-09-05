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
    @State private var showInfo = false
    @State private var didDropInitialPin = false
    @State private var placeFormatted = ""
    @State private var errorMessage = ""
    @State private var userLocation: CLLocationCoordinate2D?
    @State var showFailed = false
    private let geocoder = CLGeocoder()
    var error: APIError?
    var locationViewModel: GeoLocationViewModel
    
    var body: some View {
        VStack {
            if let userInitialPosition = locationViewModel.userLocation {
                mapContent(userInitialPosition: userInitialPosition, userLocation: locationViewModel.userLocation)
            } else {
                loadingView
            }
        }
        .alert("Location", isPresented: $showInfo, presenting: placeFormatted) { _ in
            Button("OK") { showInfo = false }
        } message: { place in
            Text(place).foregroundColor(.red)
        }
        .alert("Error", isPresented: $showFailed, presenting: error) { _ in
            Button("OK") { locationViewModel.showFailed = false }
        } message: { error in
            Text(error.errorDescription ?? "Unknown error").foregroundColor(.red)
        }
    }
}

private extension MapSection {
    
    @ViewBuilder
    func mapContent(userInitialPosition: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D?) -> some View {
        TapMapView(
            droppedPins: $droppedPins,
            userLocation: $userLocation,
            initialCenter: userInitialPosition
        )
        .frame(maxWidth: .infinity, maxHeight: 300, alignment: .top)
        .cornerRadius(30)
        .onAppear {
            dropInitialPinIfNeeded(at: userInitialPosition)
        }
        .onReceive(TapMapView.coordinatePublisher) { coordinate in
            handleMapTap(at: coordinate)
        }
    }
    
    var loadingView: some View {
        ProgressView("Getting location...")
            .frame(height: 300)
            .onChange(of: locationViewModel.showFailed) {
                showFailed = locationViewModel.showFailed
            }
    }

    func dropInitialPinIfNeeded(at location: CLLocationCoordinate2D) {
        guard !didDropInitialPin else { return }
        droppedPins.append(location)
        didDropInitialPin = true
    }
    
    func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        locationViewModel.getPlaceName(from: location)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("[Geocoder] Error: \(error.localizedDescription)")
                    showFailed = true
                }
            } receiveValue: { placeName in
                placeFormatted = placeName
                showInfo = true
            }
            .store(in: &locationViewModel.cancellables)
    }
}
