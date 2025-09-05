//
//  APIError.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 8/28/25.
//

import Foundation

// MARK: - APIError
enum APIError: Error, Equatable {
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.locationPermissionDenied, .locationPermissionDenied),
             (.noConnection, .noConnection),
             (.locationUnavailable, .locationUnavailable),
             (.geocodingFailed, .geocodingFailed):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    case locationPermissionDenied
    case noConnection
    case locationUnavailable
    case geocodingFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "Location permission denied."
        case .noConnection:
            return "No internet connection."
        case .locationUnavailable:
            return "Location unavailable."
        case .geocodingFailed:
            return "Failure geocoding location."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
