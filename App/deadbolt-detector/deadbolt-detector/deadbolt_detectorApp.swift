//
//  deadbolt_detectorApp.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 6/20/22.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct deadbolt_detectorApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}


class AppDelegate:NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        registerForPushNotifications()
        
        return true
    }
    
    func registerForPushNotifications() {
      //1
      UNUserNotificationCenter.current()
            .requestAuthorization(
               options: [.alert, .sound, .badge]) { [weak self] granted, _ in
               print("Permission granted: \(granted)")
               guard granted else { return }
               self?.getNotificationSettings()
             }

        
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }


    
}

