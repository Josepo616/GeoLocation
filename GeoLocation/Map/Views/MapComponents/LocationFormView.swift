//
//  LocationFormView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import SwiftUI

struct LocationFormView: View {

    @ObservedObject var locationViewModel: GeoLocationViewModel
    @Binding var stringLatestLocation: String
    @Binding var stringCurrentLocation: String
    @Binding var stringDistanceChanged: String

    var body: some View {
        Form {
            Section(header: Text("Latest location")) {
                TextField("N/A", text: $stringLatestLocation)
                    .disabled(true)
            }

            Section(header: Text("Current location")) {
                TextField("N/A", text: $stringCurrentLocation)
                    .disabled(true)
            }

            Section(header: Text("Distance changed")) {
                TextField("N/A", text: $stringDistanceChanged)
                    .disabled(true)
            }
        }
    }
}
