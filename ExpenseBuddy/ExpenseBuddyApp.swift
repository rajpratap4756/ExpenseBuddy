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

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                HomeView()
                    .environmentObject(authVM)
            } else {
                HomeView()
                    .environmentObject(authVM)
            }
        }
    }
}


