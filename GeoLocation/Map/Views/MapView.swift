//
//  MapView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import SwiftUI

struct MapView: View {

    @StateObject private var locationViewModel = GeoLocationViewModel()
    @Binding var stringLatestLocation: String
    @Binding var stringCurrentLocation: String
    @Binding var stringDistanceChanged: String
    @State private var selectedTab = 0
    

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                MapContentView(
                    stringLatestLocation: $stringLatestLocation,
                    stringCurrentLocation: $stringCurrentLocation,
                    stringDistanceChanged: $stringDistanceChanged,
                    locationViewModel: locationViewModel
                )
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")

                }

                VisitedPlacesView()
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Visited places")
                    }
            }
            .accentColor(.green)
        }
    }
}

#Preview {
    @Previewable @State var stringLatestLocation: String = ""
    @Previewable @State var stringCurrentLocation: String = ""
    @Previewable @State var stringDistanceChaged: String = ""

    MapView(
        stringLatestLocation: $stringLatestLocation,
        stringCurrentLocation: $stringCurrentLocation,
        stringDistanceChanged: $stringDistanceChaged
    )
}
