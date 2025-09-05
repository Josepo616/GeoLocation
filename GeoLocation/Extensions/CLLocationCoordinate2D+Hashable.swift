//
//  CLLocationCoordinate2D+Hashable.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/1/25.
//

import Foundation
import MapKit

/// Extends CLLocationCoordinate2D to conform to Hashable and Equatable protocols,
/// allowing instances to be compared for equality and used in collections like sets or dictionaries.
extension CLLocationCoordinate2D: @retroactive Equatable {}
extension CLLocationCoordinate2D: @retroactive Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
