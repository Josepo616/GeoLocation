//
//  MapContentView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//
import SwiftUI
import MapKit

struct MapContentView: View {
    
    @StateObject private var locationManager = GeoLocationViewModel()
    @Binding var stringLatestLocation: String
    @Binding var stringCurrentLocation: String
    @Binding var stringDistanceChanged: String
    @State private var droppedPins: [CLLocationCoordinate2D] = []
    @State private var mapView = MKMapView()

    private let geocoder = CLGeocoder()

    var body: some View {
        VStack {
            MapSection(
                locationManager: locationManager,
                mapView: $mapView,
                droppedPins: $droppedPins
            )

            LocationFormView(
                stringLatestLocation: $stringLatestLocation,
                stringCurrentLocation: $stringCurrentLocation,
                stringDistanceChanged: $stringDistanceChanged
            )

            TrackingControlsView()
                .padding()
        }
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { location in
            let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
                if let placemark = placemarks?.first {
                    let placeName = [
                        placemark.name,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    
                    DispatchQueue.main.async {
                        if stringLatestLocation.isEmpty {
                            stringLatestLocation = placeName
                        }
                        stringCurrentLocation = placeName
                    }
                } else if let error = error {
                    print("[Geocoder] Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
