//
//  MapContentView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//
import SwiftUI
import Combine
import MapKit

struct MapContentView: View {

    @ObservedObject var locationViewModel: GeoLocationViewModel
    @State private var mapView = MKMapView()

    var body: some View {
        VStack {
            MapSection(
                mapView: $mapView,
                droppedPins: $locationViewModel.droppedPins,
                error: locationViewModel.locationError,
                locationViewModel: locationViewModel
            )

            LocationFormView(
                locationViewModel: locationViewModel,
                stringLatestLocation: $locationViewModel.stringLatestLocation,
                stringCurrentLocation: $locationViewModel.stringCurrentLocation,
                stringDistanceChanged: $locationViewModel.stringDistanceChanged

            )
            .padding()
        }
    }
}
