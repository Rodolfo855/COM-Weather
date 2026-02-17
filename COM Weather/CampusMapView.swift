//
//  CampusMapView.swift
//  COM Weather
//
//  Created by Victor Rosales on 2/14/26.
//

import SwiftUI
import MapKit

struct CampusMapView: View {
    @Environment(\.dismiss) var dismiss
    
    private let campusCenter = CLLocationCoordinate2D(latitude: 37.9562, longitude: -122.5515)
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.9562, longitude: -122.5515),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @State private var selectedMarkerID: String? = "campus_main"
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedMarkerID) {
                Marker("College of Marin", coordinate: campusCenter)
                    .tint(.red)
                    .tag("campus_main")
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
            .safeAreaInset(edge: .bottom) {
                persistentActionCard
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
            .onAppear { fetchLookAround() }
        }
    }

    // MARK: - Persistent Action Card (Upsized)
    private var persistentActionCard: some View {
        VStack(spacing: 20) { // Increased spacing between rows
            HStack(spacing: 20) {
                // BIGGER: Increased Look Around thumbnail size
                if let lookAroundScene {
                    LookAroundPreview(initialScene: lookAroundScene)
                        .frame(width: 140, height: 95) // Increased from 110x75
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quaternary)
                        .frame(width: 140, height: 95)
                        .overlay(Image(systemName: "photo").font(.title))
                }

                VStack(alignment: .leading, spacing: 4) {
                    // BIGGER: Title and Icon
                    HStack(spacing: 6) {
                        Text("College of Marin")
                            .font(.title2) // Increased from .headline
                            .fontWeight(.bold)
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(.title3) // Increased from .subheadline
                            .foregroundStyle(.red)
                    }
                    
                    Text("Kentfield Campus")
                        .font(.headline) // Increased from .caption
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // BIGGER: Larger button with more padding
            Button(action: openInMaps) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.title3) // Increased from .headline
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18) // Increased padding
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding(12) // Increased internal padding of the card
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .padding()
    }

    func fetchLookAround() {
        Task {
            let request = MKLookAroundSceneRequest(coordinate: campusCenter)
            self.lookAroundScene = try? await request.scene
        }
    }

    func openInMaps() {
        let location = CLLocation(latitude: campusCenter.latitude, longitude: campusCenter.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = "College of Marin"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
