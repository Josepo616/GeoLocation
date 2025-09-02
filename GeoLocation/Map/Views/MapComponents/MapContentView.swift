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
            let coordinateString = "\(location.latitude), \(location.longitude)"
            
            if stringLatestLocation.isEmpty {
                stringLatestLocation = coordinateString
            }
            
            stringCurrentLocation = coordinateString
        }
    }
}
