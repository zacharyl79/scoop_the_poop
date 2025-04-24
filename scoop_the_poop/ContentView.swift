import SwiftUI
import MapKit
import UserNotifications

struct ContentView: View {
    @ObservedObject var handler: SQLiteHandler
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), // New York City
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var tappedPoop: PoopMarker?
    @State private var resolvedPoopID: [Int32: CGFloat] = [:]
    @State private var cameraOn = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
                    UserAnnotation()
                }
                .edgesIgnoringSafeArea(.all)
                .sheet(item: $tappedPoop) { val in
                    PoopDescription(handler: handler, resolvedPoopID: $resolvedPoopID, poopInfo: val)
                        .presentationDetents([.medium])
                }
                .onAppear {
                    print("Location Found")
                    // Request notification permissions
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Notification permission granted")
                        } else if let error = error {
                            print("Error requesting notification permission: \(error.localizedDescription)")
                        }
                    }
                    handler.markers.forEach { marker in
                        resolvedPoopID[marker.id] = 30
                    }
                }
                .onChange(of: locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)) { coord in //coordinate has to conform to Equatable
                    // Update the map's region when the location changes
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                    handler.markers.forEach { marker in
                        if locationManager.withinDistance(
                            userLatitude: coord.latitude,
                            userLongitude: coord.longitude,
                            markerLatitude: marker.latitude,
                            markerLongitude: marker.longitude
                        ) {
                            scheduleNotification()
                        }
                    }
                }
                Button(action: { cameraOn = true }) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $cameraOn) {
                    CameraView(handler: handler, locationManager: locationManager)
                }
                .padding()
            } else {
                ProgressView("Fetching Location...")
            }
        }
    }
}

func scheduleNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Turd Alert!"
    content.body = "There is a turd within 15 meters of you"
    content.sound = .default
    
    // Trigger notification after 1 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    // Create a request with a unique identifier
    let request = UNNotificationRequest(identifier: "uniqueIdentifier", content: content, trigger: trigger)
    
    // Add the notification to the notification center
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error adding notification: \(error.localizedDescription)")
        } else {
            print("Notification scheduled!")
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

#Preview {
    ContentView(handler: SQLiteHandler())
}
