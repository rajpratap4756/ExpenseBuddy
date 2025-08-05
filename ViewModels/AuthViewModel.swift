import Foundation
import Supabase
import Combine
import UIKit
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
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

    init() {
        Task {
            await restoreSession()
        }
    }

    func restoreSession() async {
        // Check Supabase session validity and restore user
        if let session = try? await SupabaseAuthService.shared.client.auth.session, let user = session.user as? User {
            SupabaseAuthService.shared.currentUser = user
            isLoggedIn = true
            await loadUserData()
        } else {
            isLoggedIn = false
        }
    }

    // MARK: - Auth
    func login() {
        Task {
            do {
                try await SupabaseAuthService.shared.signIn(email: email, password: password)
                isLoggedIn = true
                await loadUserData()
            } catch {
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
                try await SupabaseAuthService.shared.logout()
                isLoggedIn = false
                expenses = []
                filteredExpenses = []
                userProfile = nil
                userProfileImage = nil
            } catch {
                errorMessage = "Logout failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Profile
    func createUserProfile() async {
        guard let user = SupabaseAuthService.shared.currentUser else { return }

        let profile = Profile(
            id: user.id.uuidString,
            email: user.email ?? "",
            firstName: "User",
            lastName: "Name",
            currency: selectedCurrency
        )

        do {
            let createdProfile = try await profileService.createProfile(profile)
            userProfile = createdProfile
        } catch {
            if !error.localizedDescription.contains("duplicate") {
                errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                    offlineSyncService.queueProfileForSync(profile)
                }
            }
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
                userProfile = try await profileService.updateProfile(profile)
            }
            userProfileImage = image
        } catch {
            errorMessage = "Failed to upload profile image: \(error.localizedDescription)"
        }
    }

    // MARK: - Data Loading
    func loadUserData() async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString else { return }

        isLoading = true
        defer { isLoading = false }

        await offlineSyncService.checkNetworkStatus()
        try? await Task.sleep(nanoseconds: 500_000_000)

        do {
            // Load profile
            do {
                userProfile = try await profileService.fetchProfile(for: userId)
                selectedCurrency = userProfile?.currency ?? "$"
            } catch {
                if let fallbackProfile = try? await profileService.fetchProfileByEmail(email: SupabaseAuthService.shared.currentUser?.email ?? "") {
                    userProfile = try await profileService.updateProfile(fallbackProfile)
                    selectedCurrency = userProfile?.currency ?? "$"
                } else {
                    await createUserProfile()
                }
            }

            // Sync expenses if online
            if offlineSyncService.isOnline {
                let response: [ExpenseResponse] = try await SupabaseAuthService.shared.client
                    .from("expenses")
                    .select()
                    .eq("user_id", value: userId)
                    .order("date", ascending: false)
                    .execute()
                    .value

                let mappedExpenses = response.map { $0.toExpense() }
                self.expenses = mappedExpenses

                //let mappedExpenses = responseData.map { $0.toExpense() }

                self.expenses = mappedExpenses
                offlineSyncService.saveExpensesOffline(mappedExpenses)
            } else {
                self.expenses = offlineSyncService.loadExpensesOffline()
            }

            filterExpenses(by: selectedFilter)
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
        }
    }


    // MARK: - Expense Management
    func addExpense(category: String, amount: Double, date: Date, iconName: String) {
        let newExpense = offlineSyncService.addExpenseOffline(category: category, amount: amount, date: date, iconName: iconName)
        expenses.append(newExpense)
        filterExpenses(by: selectedFilter)
    }

    func updateExpense(_ updatedExpense: Expense) {
        offlineSyncService.updateExpenseOffline(updatedExpense)
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
        }
        filterExpenses(by: selectedFilter)
    }

    func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            offlineSyncService.deleteExpenseOffline(id: expenses[index].id)
            expenses.remove(at: index)
        }
        filterExpenses(by: selectedFilter)
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

    // MARK: - Analytics Helpers
    func formatCurrency(_ amount: Double) -> String {
        "\(selectedCurrency)\(String(format: "%.2f", amount))"
    }

    func totalAmount() -> String {
        formatCurrency(filteredExpenses.reduce(0) { $0 + $1.amount })
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

        let previousExpenses = expenses.filter { $0.date >= startDate && $0.date <= endDate }
        return formatCurrency(previousExpenses.reduce(0) { $0 + $1.amount })
    }

    func averageDailyExpense() -> Double {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { calendar.startOfDay(for: $0.date) }
        let dailyTotals = grouped.map { $0.value.reduce(0) { $0 + $1.amount } }
        return dailyTotals.isEmpty ? 0 : dailyTotals.reduce(0, +) / Double(dailyTotals.count)
    }

    func highestExpense() -> Double {
        expenses.map { $0.amount }.max() ?? 0
    }

    func lowestExpense() -> Double {
        expenses.map { $0.amount }.min() ?? 0
    }

    func expensesGroupedByMonth() -> [(key: String, value: Double)] {
        let grouped = Dictionary(grouping: expenses) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: $0.date)
        }

        return grouped.mapValues { $0.reduce(0) { $0 + $1.amount } }.sorted { $0.key < $1.key }
    }

    func expensesGroupedByIcon() -> [(iconName: String, total: Double)] {
        Dictionary(grouping: expenses, by: { $0.iconName })
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }

    // MARK: - Manual Actions
    func refreshData() async {
        await loadUserData()
    }

    func manualSync() async {
        await offlineSyncService.performSync()
        await loadUserData()
    }
}
