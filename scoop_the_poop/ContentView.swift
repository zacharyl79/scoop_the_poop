//
//  ContentView.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject private var handler: SQLiteHandler
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York City
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var tappedPoop: PoopMarker?
    @State private var resolvedPoopID: [Int32: CGFloat] = [:]
    @State private var viewModel = ViewModel()
    @State private var cameraOn = false
    
    var body: some View {
        
        if let coordinate = locationManager.lastKnownLocation {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))) {
                ForEach(handler.markers) { poop in
                    Annotation("Poop", coordinate: CLLocationCoordinate2D(latitude: poop.latitude, longitude: poop.longitude)) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .frame(width: resolvedPoopID[poop.id], height: resolvedPoopID[poop.id])
                            .animation(.easeOut(duration: 3), value: resolvedPoopID[poop.id])
                            .foregroundColor(.red)
                            .onTapGesture {
                                tappedPoop = poop // Set tapped marker when tapped
                            }
                    }
                }
                UserAnnotation() // Example: Add user location annotation
            }
            .sheet(item: $tappedPoop) { val in
                PoopDescription(resolvedPoopID: $resolvedPoopID, poopInfo: val)
                    .presentationDetents([.medium])
            }
            .onMapCameraChange(frequency: .continuous) { camera in
                print("Camera region: \(camera.region)")
            }
            .onAppear {
                handler.markers.forEach { marker in
                    resolvedPoopID[marker.id] = 30
                }
            }
        }
        else {
            Map(initialPosition: .region(region)) {
                ForEach(handler.markers) { poop in
                    Annotation("Poop", coordinate: CLLocationCoordinate2D(latitude: poop.latitude, longitude: poop.longitude)) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .frame(width: resolvedPoopID[poop.id], height: resolvedPoopID[poop.id])
                            .animation(.easeOut(duration: 3), value: resolvedPoopID[poop.id])
                            .foregroundColor(.red)
                            .onTapGesture {
                                tappedPoop = poop // Set tapped marker when tapped
                            }
                    }
                }
                UserAnnotation() // Example: Add user location annotation
            }
            .sheet(item: $tappedPoop) { val in
                PoopDescription(resolvedPoopID: $resolvedPoopID, poopInfo: val)
                    .presentationDetents([.medium])
            }
            .onMapCameraChange(frequency: .continuous) { camera in
                print("Camera region: \(camera.region)")
            }
            .onAppear {
                handler.markers.forEach { marker in
                    resolvedPoopID[marker.id] = 30
                }
            }
        }
        
        Button("camera") {
            cameraOn = true
        }
        .sheet(isPresented: $cameraOn) {
            CameraView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SQLiteHandler())
}
