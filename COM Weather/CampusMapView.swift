//
//  CampusMapView.swift
//  COM Weather
//
//  Created by Victor Rosales  on 2/14/26.
//

import SwiftUI
import MapKit

struct CampusMapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.9532, longitude: -122.5511),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                Marker("College of Marin", coordinate: CLLocationCoordinate2D(latitude: 37.9532, longitude: -122.5511)).tint(.red)
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.black)
                }
            }
        }
    }
}
