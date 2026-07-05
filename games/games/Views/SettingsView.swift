//
//  SettingsView.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import SwiftUI
struct SettingsView: View {
    // Change this from 'NotificationManager' to 'notificationManager'
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var selectedTime = Date()
    
    var body: some View {
        Form {
            DatePicker("Daily Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
            
            Button("Save Schedule") {
                // Now call the method using the lowercase instance
                notificationManager.scheduleDailyNotification(
                    at: selectedTime,
                    title: "Time to Play!",
                    body: "Don't forget to get back to the game."
                )
            }
        }
        .onAppear {
            // Use the lowercase instance here as well
            notificationManager.requestPermission()
        }
    }

}
