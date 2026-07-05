//
//  SettingsView.swift
//  games
//
//  Created by student5 on 2026-07-05.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour = 9
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute = 0
    
    @State private var selectedTime = Date()
    @State private var showResetConfirmation = false
    
    private let sessionManager = SessionManager()
    
    var body: some View {
        Form {
            Section("Daily Challenge") {
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            notificationManager.requestPermission()
                            scheduleDailyChallenge()
                        } else {
                            notificationManager.cancelDailyNotification()
                        }
                    }
                
                if notificationsEnabled {
                    DatePicker(
                        "Daily Challenge Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: selectedTime) { _, newTime in
                        saveTime(newTime)
                        scheduleDailyChallenge()
                    }
                }
            }
            
            Section {
                Button("Reset All Stats", role: .destructive) {
                    showResetConfirmation = true
                }
            }
        }
        .onAppear {
            loadSavedTime()
            if notificationsEnabled {
                notificationManager.requestPermission()
                scheduleDailyChallenge()
            }
        }
        .alert("Reset All Stats?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                sessionManager.resetAllStats()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all game sessions and high scores. This cannot be undone.")
        }
    }
    
    private func loadSavedTime() {
        var components = DateComponents()
        components.hour = dailyChallengeHour
        components.minute = dailyChallengeMinute
        selectedTime = Calendar.current.date(from: components) ?? Date()
    }
    
    private func saveTime(_ date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        dailyChallengeHour = components.hour ?? 9
        dailyChallengeMinute = components.minute ?? 0
    }
    
    private func scheduleDailyChallenge() {
        guard notificationsEnabled else { return }
        notificationManager.scheduleDailyNotification(
            at: selectedTime,
            title: "Daily Challenge Ready!",
            body: "Your daily challenge is waiting. Jump in and beat your score!"
        )
    }
}
