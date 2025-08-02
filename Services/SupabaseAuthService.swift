//
//  SupabaseAuthService.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 31/07/25.
//
import Foundation
import Supabase

final class SupabaseAuthService: ObservableObject {
    static let shared = SupabaseAuthService()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://puwtznbbhxifpaawblih.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1d3R6bmJiaHhpZnBhYXdibGloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MTIzNzgsImV4cCI6MjA2OTQ4ODM3OH0.YHqd8LtkW0m1oG7utTYw_m8RGs0F3b8QrGDhZUhA8vE"
    )
    
    @Published var currentUser: User?
    @Published var otpToken: String = ""
    
    func signIn(email: String, password: String) async throws {
        let authResponse = try await client.auth.signIn(email: email, password: password)
        if let user = authResponse.user as? User {
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } else {
            throw NSError(domain: "SupabaseAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        }
    }
    
    func signUp(email: String, password: String) async throws -> String {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["email_template": .string("{{ .Token }}")]
        )
        
        let token = authResponse.user.id.uuidString
        DispatchQueue.main.async {
            self.otpToken = token
        }
        return token
    }
    
    func verifyOTP(email: String, token: String) async throws {
        let verifyResponse = try await client.auth.verifyOTP(
            email: email,
            token: token,
            type: .signup
        )
        
        if let user = verifyResponse.user as? User {
            DispatchQueue.main.async {
                self.currentUser = user
                self.otpToken = ""
            }
        } else {
            throw NSError(domain: "SupabaseAuth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid OTP"])
        }
    }
    
    func logout() async throws {
        try await client.auth.signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
        }
    }
    
    func getCurrentSession() async throws -> Session? {
        return try await client.auth.session
    }
}

