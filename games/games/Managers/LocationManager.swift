import Foundation
import CoreLocation
import Combine
 
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
   
    static let shared = LocationManager()
 
    private let manager = CLLocationManager()
 
    private static let lastKnownLatKey = "lastKnownLatitude"
    private static let lastKnownLonKey = "lastKnownLongitude"
 
    @Published var lastLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
 
 
    var lastKnownCoordinate: CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: Self.lastKnownLatKey) != nil,
              defaults.object(forKey: Self.lastKnownLonKey) != nil else { return nil }
        return CLLocationCoordinate2D(
            latitude: defaults.double(forKey: Self.lastKnownLatKey),
            longitude: defaults.double(forKey: Self.lastKnownLonKey)
        )
    }
    
    var effectiveCoordinate: CLLocationCoordinate2D? {
        lastLocation?.coordinate ?? lastKnownCoordinate
    }
 
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
       
        self.authorizationStatus = manager.authorizationStatus
    }
 
    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
 
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
            manager.stopUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        let defaults = UserDefaults.standard
        defaults.set(location.coordinate.latitude, forKey: Self.lastKnownLatKey)
        defaults.set(location.coordinate.longitude, forKey: Self.lastKnownLonKey)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func getCurrentCoordinate() -> CLLocationCoordinate2D? {
        return lastLocation?.coordinate
    }
}
