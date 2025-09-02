//
//  LocationFormView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import SwiftUI

struct LocationFormView: View {
    
    @Binding var stringLatestLocation: String
    @Binding var stringCurrentLocation: String
    @Binding var stringDistanceChanged: String

    var body: some View {
        Form {
            Section(header: Text("Latest location")) {
                TextField("Hello example", text: $stringLatestLocation)
                    .disabled(true)
            }

            Section(header: Text("Current location")) {
                TextField("Hello example", text: $stringCurrentLocation)
                    .disabled(true)
            }

            Section(header: Text("Distance changed")) {
                TextField("Hello example", text: $stringDistanceChanged)
                    .disabled(true)
            }
        }
    }
}
