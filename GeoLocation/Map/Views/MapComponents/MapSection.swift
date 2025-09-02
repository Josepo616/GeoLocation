//
//  MapSection.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import SwiftUI
import MapKit

struct MapSection: View {
    
    @ObservedObject var locationManager: GeoLocationViewModel
    @Binding var mapView: MKMapView
    @Binding var droppedPins: [CLLocationCoordinate2D]
    @State private var didDropInitialPin = false

    var body: some View {
        VStack {
            if let userLocation = locationManager.userLocation {
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
            } else {
                ProgressView("Getting location...")
                    .frame(height: 300)
            }
        }
    }
}
