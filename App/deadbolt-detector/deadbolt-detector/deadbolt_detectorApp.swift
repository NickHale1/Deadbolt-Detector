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
    @StateObject var apiCalls = NotificationAPIRequestManager()
    let gcmMessageIDKey = "gcm.message_id"
    
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
      
      if let info = userInfo["aps"] as? NSDictionary{
          if let data = info["alert"] as? [String: String]{
              print(data["body"]!)
              if(data["body"]=="5 Minute Check"){
                  //if we confirm it is a 5 minute check notification then we need to check the database for the left unlocked flag
                  apiCalls.getData(myURL: "https://deadbolt-detector-default-rtdb.firebaseio.com/Detectors/12345.json")
                  
                  if(apiCalls.timeFlag){
                      completionHandler([[.banner, .badge, .sound]])
                  }
                  
                  /* If database says unlocked for a while
                        send out the notification with completion handler
                     Else
                        Don't send the notification
                   
                   */
                  // If the lock is found to have been open for more than 5 minutes then send the notification

              } else if(data["body"]=="Location Check") {
                  //Call the location service to get a general location
                  //determine location relative to home
                  //send the notification if far from home with the door unlocked
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


class NotificationAPIRequestManager: ObservableObject {
    private let key = "54324"
    
    @Published var result = "Unlocked"
    @Published var timeFlag = false
    @Published var resultBool=false
    @Published var inputURL = "https://deadbolt-detector-default-rtdb.firebaseio.com/Detectors/12345.json"
    
    func getData(myURL: String) {
        guard let url = URL(string: inputURL) else {
            print("invaludURL")
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            (data,response,error) in
            guard let data = data else {
                print("could not get data")
                DispatchQueue.main.async {
                    self.result = "could not get data"
                }
                return
            }
            do {
                let myresult = try JSONDecoder().decode(detector.self, from:data)
                DispatchQueue.main.async {
                    print(myresult)
                    if(myresult.status==true){
                        self.result="Locked"
                    } else {
                        self.result="Unlocked"
                    }
                    if(myresult.flag==true){
                        self.timeFlag=true
                    }else {
                        self.timeFlag=false
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
