//
//  AuthViewModel.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 31/07/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToLogin = false
    @Published var isOTPSent = false
    @Published var otpToken = ""
    @Published var expenses: [Expense] = []
    @Published var filteredExpenses: [Expense] = []
    @Published var selectedFilter: String = "Day"
    @Published var userProfileImage: UIImage?
    @Published var userProfile: Profile?
    @Published var isLoading = false
    
    @AppStorage("selectedCurrency") var selectedCurrency: String = "$"
    let availableCurrencies = ["$", "€", "₹", "£", "¥"]
    
    private let expenseService = ExpenseService.shared
    private let profileService = ProfileService.shared
    private let offlineSyncService = OfflineSyncService.shared
    
    func login() {
        Task {
            do {
                print("🔐 Attempting login for email: \(email)")
                try await SupabaseAuthService.shared.signIn(email: email, password: password)
                isLoggedIn = true
                print("✅ Login successful!")
                
                // Check current user after login
                if let user = SupabaseAuthService.shared.currentUser {
                    print("👤 Current user ID: \(user.id.uuidString)")
                    print("👤 Current user email: \(user.email ?? "No email")")
                } else {
                    print("❌ No current user found after login!")
                }
                
                // Load user profile and expenses after successful login
                print("📱 Loading user data...")
                await loadUserData()
                print("✅ User data loaded successfully!")
            } catch {
                print("❌ Login failed: \(error.localizedDescription)")
                errorMessage = "Login failed: \(error.localizedDescription)"
            }
        }
    }

    func signUp() async throws -> String {
        do {
            let token = try await SupabaseAuthService.shared.signUp(email: email, password: password)
            isOTPSent = true
            otpToken = token
            return token
        } catch {
            errorMessage = "Signup failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    func verifyOTP(token: String) async throws {
        do {
            try await SupabaseAuthService.shared.verifyOTP(email: email, token: token)
            isLoggedIn = true
            shouldNavigateToLogin = true
            isOTPSent = false
            otpToken = ""
            
            // Create user profile and load data after successful OTP verification
            await createUserProfile()
            await loadUserData()
        } catch {
            errorMessage = "OTP verification failed: \(error.localizedDescription)"
            throw error
        }
    }

    func logout() {
        Task {
            do {
                print("🚪 Attempting logout...")
                try await SupabaseAuthService.shared.logout()
                isLoggedIn = false
                
                // Clear local data
                expenses = []
                filteredExpenses = []
                userProfile = nil
                userProfileImage = nil
                print("✅ Logout successful! Local data cleared.")
            } catch {
                print("❌ Logout failed: \(error.localizedDescription)")
                errorMessage = "Logout failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Expense Management
    func addExpense(category: String, amount: Double, date: Date, iconName: String) {
        // Use offline-first approach
        let newExpense = offlineSyncService.addExpenseOffline(category: category, amount: amount, date: date, iconName: iconName)
        expenses.append(newExpense)
        filterExpenses(by: selectedFilter)
    }

    func updateExpense(_ updatedExpense: Expense) {
        // Use offline-first approach
        offlineSyncService.updateExpenseOffline(updatedExpense)
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
        }
        filterExpenses(by: selectedFilter)
    }

    func deleteExpense(at offsets: IndexSet) {
        // Use offline-first approach
        for index in offsets {
            let expense = expenses[index]
            offlineSyncService.deleteExpenseOffline(id: expense.id)
            expenses.remove(at: index)
        }
        filterExpenses(by: selectedFilter)
    }

        func formatCurrency(_ amount: Double) -> String {
            return "\(selectedCurrency)\(String(format: "%.2f", amount))"
        }
        
        func totalAmount() -> String {
            return formatCurrency(filteredExpenses.reduce(0) { $0 + $1.amount })
        }
        
        func previousPeriodTotal() -> String {
            let calendar = Calendar.current
            let now = Date()
            var startDate: Date
            var endDate: Date
            
            switch selectedFilter {
            case "Day":
                startDate = calendar.date(byAdding: .day, value: -2, to: now)!
                endDate = calendar.date(byAdding: .day, value: -1, to: now)!
            case "Week":
                startDate = calendar.date(byAdding: .day, value: -14, to: now)!
                endDate = calendar.date(byAdding: .day, value: -7, to: now)!
            case "Month":
                startDate = calendar.date(byAdding: .month, value: -2, to: now)!
                endDate = calendar.date(byAdding: .month, value: -1, to: now)!
            case "Year":
                startDate = calendar.date(byAdding: .year, value: -2, to: now)!
                endDate = calendar.date(byAdding: .year, value: -1, to: now)!
            default:
                return formatCurrency(0.0)
            }
            
            let previousPeriodExpenses = expenses.filter { $0.date >= startDate && $0.date <= endDate }
            return formatCurrency(previousPeriodExpenses.reduce(0) { $0 + $1.amount })
        }
    
    func expensesGroupedByMonth() -> [(key: String, value: Double)] {
        let grouped = Dictionary(grouping: expenses) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: $0.date)
        }
        return grouped.mapValues { group in
            group.reduce(0) { $0 + $1.amount }
        }.sorted { $0.key < $1.key }
    }

    func expensesGroupedByIcon() -> [(iconName: String, total: Double)] {
        let grouped = Dictionary(grouping: expenses, by: { $0.iconName })
            .map { (key, value) in
                (iconName: key, total: value.reduce(0) { $0 + $1.amount })
            }
        return grouped.sorted { $0.iconName < $1.iconName }
    }



    func averageDailyExpense() -> Double {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: expenses) {
            calendar.startOfDay(for: $0.date)
        }
        let dailyTotals = groupedByDay.map { $0.value.reduce(0) { $0 + $1.amount } }
        guard !dailyTotals.isEmpty else { return 0 }
        return dailyTotals.reduce(0, +) / Double(dailyTotals.count)
    }

    func highestExpense() -> Double {
        expenses.map { $0.amount }.max() ?? 0
    }

    func lowestExpense() -> Double {
        expenses.map { $0.amount }.min() ?? 0
    }
    
    func filterExpenses(by filter: String) {
        selectedFilter = filter
        let calendar = Calendar.current
        let now = Date()
        
        switch filter {
        case "Day":
            filteredExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case "Week":
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            filteredExpenses = expenses.filter { $0.date >= weekAgo && $0.date <= now }
        case "Month":
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            filteredExpenses = expenses.filter { $0.date >= monthAgo && $0.date <= now }
        case "Year":
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            filteredExpenses = expenses.filter { $0.date >= yearAgo && $0.date <= now }
        default:
            filteredExpenses = expenses
        }
    }
    
    func saveProfileImage(image: UIImage) {
        self.userProfileImage = image
    }
    
    // MARK: - Profile Management
    func loadUserData() async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString else { 
            print("❌ No user ID found for loading data")
            return 
        }
        
        print("👤 Loading data for user ID: \(userId)")
        print("👤 Current user email: \(SupabaseAuthService.shared.currentUser?.email ?? "No email")")
        isLoading = true
        defer { isLoading = false }
        
        // Check network status first
        await offlineSyncService.checkNetworkStatus()
        
        // Add a small delay to show loading state
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        do {
            // Load profile
            print("📋 Fetching user profile...")
            do {
                let profile = try await profileService.fetchProfile(for: userId)
                userProfile = profile
                selectedCurrency = profile.currency
                print("✅ Profile loaded: \(profile.fullName) (\(profile.email))")
            } catch {
                print("⚠️ Profile fetch failed, checking if profile exists with different data...")
                // Try to update existing profile with missing data
                if let existingProfile = try? await profileService.fetchProfileByEmail(email: SupabaseAuthService.shared.currentUser?.email ?? "") {
                    print("✅ Found existing profile by email, updating...")
                    let updatedProfile = Profile(
                        id: existingProfile.id,
                        email: existingProfile.email,
                        firstName: existingProfile.firstName.isEmpty ? "User" : existingProfile.firstName,
                        lastName: existingProfile.lastName.isEmpty ? "Name" : existingProfile.lastName,
                        phoneNumber: existingProfile.phoneNumber,
                        dateOfBirth: existingProfile.dateOfBirth,
                        profileImageUrl: existingProfile.profileImageUrl,
                        currency: existingProfile.currency,
                        timezone: existingProfile.timezone
                    )
                    let savedProfile = try await profileService.updateProfile(updatedProfile)
                    userProfile = savedProfile
                    selectedCurrency = savedProfile.currency
                    print("✅ Profile updated: \(savedProfile.fullName) (\(savedProfile.email))")
                } else {
                    print("❌ No existing profile found, creating new one...")
                    // Check if profile already exists by trying to create it
                    do {
                        await createUserProfile()
                    } catch {
                        // If creation fails, the profile might already exist
                        print("⚠️ Profile creation failed, profile might already exist")
                        // Don't queue for sync if creation failed - it might already exist
                    }
                }
            }
            
            // Load expenses with offline-first approach
            print("💰 Loading expenses...")
            if offlineSyncService.isOnline {
                // Try to sync and get latest data
                do {
                    await offlineSyncService.performSync()
                    print("✅ Sync completed successfully")
                } catch {
                    print("⚠️ Sync failed, continuing with local data: \(error.localizedDescription)")
                }
            } else {
                print("📱 Offline mode - using local data only")
            }
            
            // Load from local storage
            let localExpenses = offlineSyncService.loadExpensesOffline()
            expenses = localExpenses
            filterExpenses(by: selectedFilter)
            print("✅ Loaded \(expenses.count) expenses (offline-first)")
            
            // Print some expense details for debugging
            for (index, expense) in localExpenses.enumerated() {
                print("   Expense \(index + 1): \(expense.category) - \(expense.amount) - \(expense.date)")
            }
        } catch {
            print("❌ Failed to load user data: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
            
            // Try to create a basic profile as fallback
            print("🔄 Attempting to create fallback profile...")
            await createUserProfile()
        }
    }
    
    func createUserProfile() async {
        guard let user = SupabaseAuthService.shared.currentUser else { return }
        
        do {
            print("📝 Creating profile for user: \(user.id.uuidString)")
            let profile = Profile(
                id: user.id.uuidString,
                email: user.email ?? "",
                firstName: "User",
                lastName: "Name",
                currency: selectedCurrency
            )
            
            let createdProfile = try await profileService.createProfile(profile)
            userProfile = createdProfile
            print("✅ Profile created successfully: \(createdProfile.fullName)")
        } catch {
            print("❌ Failed to create user profile: \(error.localizedDescription)")
            
            // Only queue for sync if it's not a duplicate error
            if !error.localizedDescription.contains("duplicate") {
                errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                // --- Queue for retry if network error ---
                if let urlError = error as? URLError, urlError.code == .notConnectedToInternet || urlError.code == .timedOut || urlError.code == .networkConnectionLost || urlError.code == .cancelled {
                    OfflineSyncService.shared.queueProfileForSync(Profile(
                        id: user.id.uuidString,
                        email: user.email ?? "",
                        firstName: "User",
                        lastName: "Name",
                        currency: selectedCurrency
                    ))
                    print("⏳ Profile queued for sync when network returns")
                }
            } else {
                print("📝 Profile already exists, not queuing for sync")
            }
        }
    }
    
    // MARK: - Test Functions
    func testSupabaseConnection() async {
        print("🧪 Testing Supabase connection...")
        
        do {
            // Test basic connection
            let response: [String] = try await SupabaseAuthService.shared.client
                .from("profiles")
                .select("id")
                .limit(1)
                .execute()
                .value
            
            print("✅ Supabase connection successful! Found \(response.count) records in profiles table")
        } catch {
            print("❌ Supabase connection failed: \(error.localizedDescription)")
            print("❌ This might mean:")
            print("   1. Database schema is not set up")
            print("   2. RLS policies are blocking access")
            print("   3. Supabase credentials are incorrect")
        }
    }
    
    func debugUserAndExpenses() async {
        print("🔍 Debugging user and expenses...")
        
        // Check current user
        if let user = SupabaseAuthService.shared.currentUser {
            print("👤 Current user ID: \(user.id.uuidString)")
            print("👤 Current user email: \(user.email ?? "No email")")
        } else {
            print("❌ No current user found!")
            return
        }
        
        // Try to get all expenses (for debugging)
        do {
            let allExpenses: [ExpenseResponse] = try await SupabaseAuthService.shared.client
                .from("expenses")
                .select()
                .execute()
                .value
            
            print("📊 Found \(allExpenses.count) total expenses in database:")
            for (index, expense) in allExpenses.enumerated() {
                print("   Expense \(index + 1): ID=\(expense.id), Category=\(expense.category), Amount=\(expense.amount), UserID=\(expense.user_id)")
            }
        } catch {
            print("❌ Failed to fetch all expenses: \(error.localizedDescription)")
        }
    }
    
    func updateUserProfile(_ profile: Profile) async {
        do {
            let updatedProfile = try await profileService.updateProfile(profile)
            userProfile = updatedProfile
            selectedCurrency = updatedProfile.currency
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }
    
    func uploadProfileImage(_ image: UIImage) async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            let imageUrl = try await profileService.uploadProfileImage(userId: userId, imageData: imageData)
            
            if var profile = userProfile {
                profile.profileImageUrl = imageUrl
                let updatedProfile = try await profileService.updateProfile(profile)
                userProfile = updatedProfile
            }
            
            userProfileImage = image
        } catch {
            errorMessage = "Failed to upload profile image: \(error.localizedDescription)"
        }
    }
    
    func deleteUserProfile() async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString else { return }
        
        do {
            try await profileService.deleteProfile(id: userId)
            userProfile = nil
        } catch {
            errorMessage = "Failed to delete profile: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Manual Refresh
    func refreshData() async {
        print("🔄 Manual refresh triggered")
        await loadUserData()
    }
    
    // MARK: - Manual Sync
    func manualSync() async {
        print("🔄 Manual sync triggered")
        await offlineSyncService.performSync()
        await loadUserData()
    }
    
}
