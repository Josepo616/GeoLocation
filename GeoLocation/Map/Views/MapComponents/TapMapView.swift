//
//  TapMapView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import SwiftUI
import MapKit

struct TapMapView: UIViewRepresentable {
    
    @Binding var droppedPins: [CLLocationCoordinate2D]
    var initialCenter: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        if let center = initialCenter {
            let region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
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

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TapMapView

        init(_ parent: TapMapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            if let mapView = gestureRecognizer.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

                DispatchQueue.main.async {
                    if !self.parent.droppedPins.isEmpty {
                        self.parent.droppedPins.removeLast()
                    }
                    self.parent.droppedPins.append(coordinate)
                }
            }
        }
    }
}
