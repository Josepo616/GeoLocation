//
//  GeoLocationApp.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import SwiftUI

@main
struct GeoLocationApp: App {
    @State var stringLatestLocation: String = ""
    @State var stringCurrentLocation: String = ""
    @State var stringDistanceChaged: String = ""

    var body: some Scene {
        WindowGroup {
            MapView(
                stringLatestLocation: $stringLatestLocation,
                stringCurrentLocation: $stringCurrentLocation,
                stringDistanceChanged: $stringDistanceChaged
            )
        }
    }
}
