//
//  LocationErrorMapper.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import CoreLocation

enum LocationErrorMapper {
    static func map(_ error: Error) -> APIError {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                return .locationPermissionDenied
            case .network:
                return .noConnection
            case .locationUnknown:
                return .locationUnavailable
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
}
