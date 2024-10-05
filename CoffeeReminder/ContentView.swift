import SwiftUI
import UserNotifications

struct ContentView: View {
    // State to track selected hours and minutes
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var showAlert = false // State variable for showing the alert
    @State private var isReminderSet = false // Track if a reminder is set
    @State private var remainingTime: TimeInterval = 0 // Countdown remaining time
    @State private var timer: Timer? // Reference to the countdown timer
    
    // Maximum hours and minutes range
    let hoursRange = Array(0...23) // Hours: 0 to 23
    let minutesRange = Array(0...59) // Minutes: 0 to 59
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("coffee_cup")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .background(Color.clear)
                .padding(.top, 50)
            
            Spacer()
            
            Text("Select Coffee Reminder Interval")
                .font(.headline)
                .foregroundColor(.white)
            
            // Balanced scrolling pickers for hours and minutes
            HStack(spacing: 0) {
                // Hours Picker
                Picker(selection: $selectedHours, label: Text("Hours")) {
                    ForEach(hoursRange, id: \.self) { hour in
                        Text("\(hour) hr")
                            .foregroundColor(.white) // Set picker text to white
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 150) // Ensures even height
                .clipped() // Clip to frame size
                .pickerStyle(WheelPickerStyle()) // Wheel picker style
                
                // Separator between pickers (Optional)
                Text(":")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                
                // Minutes Picker
                Picker(selection: $selectedMinutes, label: Text("Minutes")) {
                    ForEach(minutesRange, id: \.self) { minute in
                        Text("\(minute) min")
                            .foregroundColor(.white) // Set picker text to white
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 150) // Ensures even height
                .clipped() // Clip to frame size
                .pickerStyle(WheelPickerStyle()) // Wheel picker style
            }
            .padding()
            
            Spacer()
                .frame(height: 20)
            
            // Show countdown timer if the reminder is set
            if isReminderSet {
                Text("Time remaining: \(formatTime(remainingTime))")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Cancel Reminder Button
                Button(action: {
                    cancelReminder()
                }) {
                    Text("Cancel Reminder")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            
            // Button to Set Reminder (disabled when reminder is active)
            Button(action: {
                setReminder()
            }) {
                Text("Set Reminder")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 1.0, green: 0.98, blue: 0.85)) // Cream color background
                    .foregroundColor(.black) // Darker text color to contrast the cream button
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .disabled(isReminderSet) // Disable the button when the timer is running
            
            Spacer()
        }
        .background(Color.brown.edgesIgnoringSafeArea(.all))
        .onAppear {
            NotificationManager.shared.requestNotificationAuthorization()
        }
    }
    
    // Set the coffee reminder
    func setReminder() {
        // Convert selected hours and minutes to total seconds
        let totalSeconds = (selectedHours * 3600) + (selectedMinutes * 60)
        
        // Ensure the time is valid (not zero)
        if totalSeconds > 0 {
            NotificationManager.shared.scheduleCoffeeReminder(after: TimeInterval(totalSeconds))
            showAlert = true // Show alert after setting reminder
            isReminderSet = true // Mark reminder as set
            remainingTime = TimeInterval(totalSeconds) // Set the countdown time
            startCountdown() // Start the countdown timer
        }
    }
    
    // Start the countdown timer
    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
                isReminderSet = false
            }
        }
    }
    
    // Cancel the reminder
    func cancelReminder() {
        timer?.invalidate()
        remainingTime = 0
        isReminderSet = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // Cancel notifications
    }
    
    // Format time into hours and minutes
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
