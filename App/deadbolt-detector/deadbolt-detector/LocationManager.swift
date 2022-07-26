//
//  LocationManager.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 7/25/22.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    func requestLocation(){
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            print("Location status: Not determined")
        case .restricted:
            print("Location status: Restricted")

        case .denied:
            print("Location status: Denied")

        case .authorizedAlways:
            print("Location status: Authirzed Always")

        case .authorizedWhenInUse:
            print("Location status: Authorized in use")

        @unknown default:
            print("Location status: default statement idk what we got goin on here")
            break

        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.userLocation=location
    }
}
