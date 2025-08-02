//
//  SessionManager.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 31/07/25.
//

//import Foundation
//import Supabase
//
//@MainActor
//class SessionManager: ObservableObject {
//    static let shared = SessionManager()
//    
//    @Published var isLoggedIn = false
//    let client = SupabaseClient(supabaseURL: URL(string: "https://puwtznbbhxifpaawblih.supabase.co")!,
//                                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1d3R6bmJiaHhpZnBhYXdibGloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MTIzNzgsImV4cCI6MjA2OTQ4ODM3OH0.YHqd8LtkW0m1oG7utTYw_m8RGs0F3b8QrGDhZUhA8vE")
//    
//    init() {} // Not private
//
//    
//    func signOut() {
//        Task {
//            try? await client.auth.signOut()
//            DispatchQueue.main.async {
//                self.isLoggedIn = false
//            }
//        }
//    }
//
//    func login(email: String, password: String) {
//        Task {
//            do {
//                try await client.auth.signIn(email: email, password: password)
//                DispatchQueue.main.async {
//                    self.isLoggedIn = true
//                }
//            } catch {
//                print("Login failed:", error)
//            }
//        }
//    }
//
//    func signUp(email: String, password: String) {
//        Task {
//            do {
//                try await client.auth.signUp(email: email, password: password)
//                DispatchQueue.main.async {
//                    self.isLoggedIn = true
//                }
//            } catch {
//                print("Signup failed:", error)
//            }
//        }
//    }
//}
