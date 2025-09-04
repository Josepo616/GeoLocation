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

    @State private var droppedPins: [CLLocationCoordinate2D] = []
    @State private var mapView = MKMapView()
    @ObservedObject var locationViewModel: GeoLocationViewModel

    var body: some View {
        VStack {
            MapSection(
                mapView: $mapView,
                droppedPins: $droppedPins,
                error: locationViewModel.locationError,
                locationViewModel: locationViewModel
            )

            LocationFormView(
                stringLatestLocation: $locationViewModel.stringLatestLocation,
                stringCurrentLocation: $locationViewModel.stringCurrentLocation,
                stringDistanceChanged: $locationViewModel.stringDistanceChanged,
                locationViewModel: locationViewModel

            )

            TrackingControlsView(locationViewModel: locationViewModel)
                .padding()
        }
    }
}
