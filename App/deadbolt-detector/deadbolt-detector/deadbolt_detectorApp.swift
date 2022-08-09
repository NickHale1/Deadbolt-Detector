//
//  deadbolt_detectorApp.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 6/20/22.
//

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging

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


class AppDelegate: NSObject, UIApplicationDelegate {
    @EnvironmentObject var viewModel: AppViewModel
    @StateObject var apiCalls = APIRequestManager()
    let gcmMessageIDKey = "gcm.message_id"
    var myFlag = "nil"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        //registerForPushNotifications()
        
        //Setup cloud messaging
        Messaging.messaging().delegate = self
        
        //Setup notifications
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
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

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
     
        //Store token in Database for sending notigication from server in future
        
        print(dataDict)
    }  
}


//user notifications
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
   
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo
      print(notification.request)
      
      print(notification.request.content)

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Do something with MSG data
    

    // Print full message.
      print("!!!!!!!!!!This is Info Time!!!!!!!")
      print(userInfo)
      print("!!!!!!!!!!!!!debug desc!!!!!!!!!!!")
      print(userInfo.debugDescription)
      print("!!!!!!!!!!!!!!!!Values!!!!!!!!!!!!")
      print(userInfo.values)
      print("!!!!!!!!!!!!!!!Keys!!!!!!!!!!!!!!!")
      print(userInfo.keys)
      print(userInfo)
      print("testforlocal")
      print(notification.request.content.title)
      if(notification.request.content.title=="Did you forget to lock your door?"){
          completionHandler([[.banner, .badge, .sound]])
      }
     
      if let info = userInfo["aps"] as? NSDictionary{
          if let data = info["alert"] as? [String: String]{
              print(data["body"]!)
              if(data["title"]=="Don't forget to lock your door!"){
                  var result = "nil"
                  let inputURL = "https://deadbolt-detector-default-rtdb.firebaseio.com/Flags/12345.json"
                  guard let url = URL(string: inputURL) else {
                      print("invaludURL")
                      return
                  }
                  URLSession.shared.dataTask(with: url) {
                      (data,response,error) in
                      guard let data = data else {
                          print("could not get data")
                          DispatchQueue.main.async {
                              result = "could not get data"
                          }
                          return
                      }
                      do {
                          let myresult = try JSONDecoder().decode(detector.self, from:data)
                          DispatchQueue.main.async {
                              print(myresult)
                              if(myresult.status==true){
                                  print("reached here")
                                  result="flag is up"
                                  if(self.viewModel.flagNotifications) {
                                      completionHandler([[.banner, .badge, .sound]])
                                  }
                                  
                                  print(result)
                              }else {
                                  print("reached flag down")
                                  result="flag is down"
                              }
                          }
                      } catch {
                          DispatchQueue.main.async {
                              print("\(error)")
                          }
                      }
                      
                  }
                  .resume()
                 

              }
          }
      }
    // Change this to your preferred presentation option
     
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}



