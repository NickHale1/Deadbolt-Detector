//
//  NotificationManager.swift
//  deadbolt-detector
//
//  Created by Nick Hale on 7/15/22.
//

import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published private(set) var notifications: [UNNotificationRequest] = []
    
    
    
}
