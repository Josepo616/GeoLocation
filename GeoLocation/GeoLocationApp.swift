//
//  GeoLocationApp.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import SwiftUI

@main
struct GeoLocationApp: App {
    
    @StateObject private var locationViewModel = GeoLocationViewModel()
    
    var body: some Scene {
        WindowGroup {
            MapView(
                locationViewModel: locationViewModel
            )
        }
    }
}
