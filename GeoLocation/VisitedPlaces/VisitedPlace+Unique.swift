//
//  VisitedPlace+Unique.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/4/25.
//

import Foundation

extension VisitedPlaceModel {
    func isDuplicate(of other: VisitedPlaceModel) -> Bool {
        return self.name == other.name &&
               self.location.latitude == other.location.latitude &&
               self.location.longitude == other.location.longitude
    }
}
