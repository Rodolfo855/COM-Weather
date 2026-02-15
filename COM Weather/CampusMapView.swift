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
    
    // Static coordinate to keep the initializer fast
    private let campusCenter = CLLocationCoordinate2D(latitude: 37.9545, longitude: -122.5497)
    
    // Start with a standard automatic position to avoid early heavy rendering
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                Marker("College of Marin", coordinate: campusCenter)
                    .tint(.red)
            }
            // Simplified style to fix the "StandardEmphasis" compiler error
            .mapStyle(.standard)
            .onAppear {
                // Smooth transition to the region on a slight delay
                // to prevent "Main Thread" hitching during the view slide-in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn) {
                        position = .region(
                            MKCoordinateRegion(
                                center: campusCenter,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
