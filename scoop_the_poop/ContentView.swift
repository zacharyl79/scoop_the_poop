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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York City -> Should be changed to user location
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var tappedPoop: PoopMarker?
    
    var body: some View {
        Map(initialPosition: .region(region)) {
            ForEach(handler.markers) { poop in
                Marker("Poop", coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
                    /*.onTapGesture {
                        tappedPoop = poop
                    }
                    .sheet(item: $tappedPoop) { val in
                        PoopDescription(poopInfo: val)
                    }
                     */
            }
            
            UserAnnotation() // Example: Add user location annotation
        }
        .onMapCameraChange(frequency: .continuous) { camera in
            print("Camera region: \(camera.region)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SQLiteHandler())
}
