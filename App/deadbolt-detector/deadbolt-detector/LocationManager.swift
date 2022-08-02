//
//  LocationManager.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 7/25/22.
//

import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject {
    private var homeLocation: CLLocation!
    private let manager = CLLocationManager()
    private var alreadyBreached = false
    @Published var userLocation: CLLocation?
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    func requestLocation(){
        manager.requestAlwaysAuthorization()
        print(self.userLocation)
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
        if(homeLocation==nil){
            self.homeLocation=location
        }
        self.userLocation=location
        print(self.userLocation)
        
        let distanceThreshold = 20.0 // meters
        
        if(location.distance(from: homeLocation) > distanceThreshold && !alreadyBreached){
            
            let inputURL = "https://deadbolt-detector-default-rtdb.firebaseio.com/Detectors/12345.json"
            guard let url = URL(string: inputURL) else {
                print("invaludURL")
                return
            }
            URLSession.shared.dataTask(with: url) {
                (data,response,error) in
                guard let data = data else {
                    print("could not get data")
                    DispatchQueue.main.async {
                        
                    }
                    return
                }
                do {
                    let myresult = try JSONDecoder().decode(detector.self, from:data)
                    DispatchQueue.main.async {
                        print(myresult)
                        if(myresult.status==true){
                            //the door is locked
                         
                        }else {
                            //the door is unlocked
                            let content = UNMutableNotificationContent()
                            content.title = "Did you forget to lock your door?"
                            content.body = "It looks like you forgot to lock your door on your way out"
                            content.sound = UNNotificationSound.default

                            // show this notification five seconds from now
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                            // choose a random identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                            // add our notification request
                            UNUserNotificationCenter.current().add(request)

                           
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("\(error)")
                    }
                }
                
            }
            .resume()
            //send notification
            
            alreadyBreached=true
        }else if (location.distance(from: homeLocation) < distanceThreshold && alreadyBreached){
            alreadyBreached=false
        }
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("started monitoring significant")
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        manager.stopMonitoringSignificantLocationChanges()
        print("stopped monitoring significant")
    }
    
    
    
    
}
