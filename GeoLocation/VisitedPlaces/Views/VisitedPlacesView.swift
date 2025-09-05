//
//  VisitedPlacesView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import SwiftUI

struct VisitedPlacesView: View {
    var visitedPlaces: [VisitedPlaceModel]

    var body: some View {
        if visitedPlaces.isEmpty {
            Text("No visited places yet.")
                .font(.headline)
                .foregroundColor(.gray)
        } else {
            List(visitedPlaces) { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.headline)
                    Text("Lat: \(place.location.latitude), Lon: \(place.location.longitude)")
                        .font(.subheadline)
                    Text("Visited at: \(place.timestamp.formatted(.dateTime.hour().minute().second()))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
