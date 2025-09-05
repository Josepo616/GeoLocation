//
//  TapMapView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import Combine
import MapKit
import SwiftUI

/// A custom SwiftUI view that wraps MKMapView to handle user interactions such as tapping
/// on the map to drop pins, and displaying user location on the map.
struct TapMapView: UIViewRepresentable {

    @Binding var droppedPins: [CLLocationCoordinate2D]
    @Binding var userLocation: CLLocationCoordinate2D?
    var initialCenter: CLLocationCoordinate2D?

    static let coordinatePublisher = PassthroughSubject<
        CLLocationCoordinate2D, Never
    >()

    /// Creates and configures the MKMapView instance with the provided initial region,
    /// user location tracking, and tap gesture recognizer.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        if let center = initialCenter {
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
            mapView.setRegion(region, animated: true)
        }
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tapGesture)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        for coordinate in droppedPins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Coordinator class to manage the interactions on the MKMapView, such as handling
    /// tap gestures and publishing coordinates when the map is tapped.
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TapMapView
        let coordinatePublisher = PassthroughSubject<
            CLLocationCoordinate2D, Never
        >()

        init(_ parent: TapMapView) {
            self.parent = parent
        }

        /// Handles tap gestures on the map, converts the tapped location to a coordinate,
        /// and adds the pin to the map.
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else {
                return
            }
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(
                location,
                toCoordinateFrom: mapView
            )

            self.coordinatePublisher.send(coordinate)
            TapMapView.coordinatePublisher.send(coordinate)
            self.parent.droppedPins.append(coordinate)
        }
    }
}
