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
    
    // Coordinates provided for the COM Building
    private let campusCenter = CLLocationCoordinate2D(latitude: 37.9555, longitude: -122.5497)
    
    // Helper to get the standard reset region
    private var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: campusCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.9555, longitude: -122.5497),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @State private var selectedMarkerID: String? = "campus_main"
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Map(position: $position, selection: $selectedMarkerID) {
                    Annotation("COM Building", coordinate: campusCenter) {
                        Image("comIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(lineWidth: 1))
                            .shadow(radius: 4)
                    }
                    .tag("campus_main")
                    
                 
                }
                .mapControls {
                    MapCompass()
                    MapPitchToggle()
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
                
                // --- CUSTOM RESET BUTTON (Replaces Location Button) ---
                // This resets the camera to campus without requesting GPS
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        position = .region(defaultRegion)
                    }
                } label: {
                    Image(systemName: "scope")
                        .font(.title)
                        .padding(15)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
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
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                if let lookAroundScene {
                    LookAroundPreview(initialScene: lookAroundScene)
                        .frame(width: 140, height: 95)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quaternary)
                        .frame(width: 140, height: 95)
                        .overlay(Image(systemName: "photo").font(.title))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("College of Marin")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    
                    Text("Kentfield Campus")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Button(action: openInMaps) {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
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
