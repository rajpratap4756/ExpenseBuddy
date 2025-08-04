//
//  ExpenseBuddyApp.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 31/07/25.
//

import SwiftUI

@main
struct ExpenseBuddyApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var offlineSyncService = OfflineSyncService.shared

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                HomeView()
                    .environmentObject(authVM)
                    .environmentObject(offlineSyncService)
            } else {
                LoginView()
                    .environmentObject(authVM)
                    .environmentObject(offlineSyncService)
            }
        }
    }
}


