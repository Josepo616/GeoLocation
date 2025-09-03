//
//  CLGeocoder+Combine.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/3/25.
//

import Combine
import CoreLocation

extension CLGeocoder {
    func reverseGeocodePublisher(for location: CLLocation) -> Future<
        CLPlacemark, Error
    > {
        Future { promise in
            self.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(error))
                } else if let placemarks = placemarks?.first {
                    promise(.success(placemarks))
                } else {
                    promise(
                        .failure(
                            NSError(
                                domain: "GeocoderError",
                                code: 0,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "No placemark found"
                                ]
                            )
                        )
                    )
                }
            }
        }
    }
}
