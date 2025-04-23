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
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .onTapGesture {
                                tappedPoop = poop // Set tapped marker when tapped
                            }
                    }
                }
                
                UserAnnotation() // Example: Add user location annotation
            }
            .sheet(item: $tappedPoop) { val in
                PoopDescription(poopInfo: val)
                    .presentationDetents([.medium])
            }
            .onMapCameraChange(frequency: .continuous) { camera in
                print("Camera region: \(camera.region)")
            }
        }
        else {
            Map(initialPosition: .region(region)) {
                ForEach(handler.markers) { poop in
                    Annotation("Poop", coordinate: CLLocationCoordinate2D(latitude: poop.latitude, longitude: poop.longitude)) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .onTapGesture {
                                tappedPoop = poop // Set tapped marker when tapped
                            }
                    }
                }
                UserAnnotation() // Example: Add user location annotation
            }
            .sheet(item: $tappedPoop) { val in
                PoopDescription(poopInfo: val)
                    .presentationDetents([.medium])
            }
            .onMapCameraChange(frequency: .continuous) { camera in
                print("Camera region: \(camera.region)")
            }
        }
        Button(action: {
            cameraOn.toggle()
        }) {
            Image(systemName: "camera")
        }
        .sheet(isPresented: $cameraOn) {
            CameraView(image: $viewModel.currentFrame)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SQLiteHandler())
}
