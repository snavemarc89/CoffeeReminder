import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    // Request notification authorization from the user
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }
    
    // Schedule a local notification for a coffee reminder
    func scheduleCoffeeReminder(after interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Coffee Reminder ☕️"
        content.body = "Time for a coffee break! Enjoy your coffee."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}
