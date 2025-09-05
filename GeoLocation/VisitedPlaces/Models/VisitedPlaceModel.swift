//
//  VisitedPlaceModel.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/4/25.
//

import Foundation
import CoreLocation

struct VisitedPlaceModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
    let date: Date
    let timestamp: Date
    var distanceFromStart: Double?
}
