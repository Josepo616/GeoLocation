//
//  MapView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import SwiftUI

struct MapView: View {
    
    @ObservedObject var locationViewModel: GeoLocationViewModel

    var body: some View {
        VStack {
            TabView {
                MapContentView(locationViewModel: locationViewModel)
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }

                VisitedPlacesView(visitedPlaces: locationViewModel.visitedPlaces)
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Visited places")
                    }
            }
            .accentColor(.green)
        }
    }
}

/*
#Preview {
    @Previewable @State var stringLatestLocation: String = ""
    @Previewable @State var stringCurrentLocation: String = ""
    @Previewable @State var stringDistanceChaged: String = ""
    @Previewable @State var visitedPlaces: [String] = []
    

    MapView(
        stringLatestLocation: $stringLatestLocation,
        stringCurrentLocation: $stringCurrentLocation,
        stringDistanceChanged: $stringDistanceChaged,
        vistiedPlaces: $visitedPlaces
    )
}
*/
