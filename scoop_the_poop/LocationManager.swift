import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    private var manager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        print("Auth status: \(manager.authorizationStatus.rawValue)")
    }
    
    // Triggered when location permission changes (e.g., user taps "Allow")
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Location denied or restricted")
        case .notDetermined:
            print("⏳ Waiting for user decision...")
        @unknown default:
            print("⚠️ Unknown location authorization status")
        }
    }
    
    // Called every time the location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        lastKnownLocation = coordinate
        print("📍 Updated location: \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // Optional helper to check if a marker is close to the user
    func withinDistance(userLatitude: Double, userLongitude: Double, markerLatitude: Double, markerLongitude: Double, threshold: Double = 15) -> Bool {
        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
        let markerLocation = CLLocation(latitude: markerLatitude, longitude: markerLongitude)
        return markerLocation.distance(from: userLocation) < threshold
    }
}
