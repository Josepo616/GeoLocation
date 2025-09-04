//
//  TrackingControlsView.swift
//  GeoLocation
//
//  Created by JoseAlvarez on 9/2/25.
//

import SwiftUI
import CoreLocation

struct TrackingControlsView: View {
    
    @ObservedObject var locationViewModel: GeoLocationViewModel

    var body: some View {
        HStack(spacing: 16) {            
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "restart")
                        .frame(width: 24, height: 24)
                    Text("Track my position")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }

            Button(action: {
                print("second")
            }) {
                HStack {
                    Image(systemName: "stop")
                        .frame(width: 24, height: 24)
                    Text("End my tracking")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}
