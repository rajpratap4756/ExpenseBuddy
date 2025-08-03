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
    
    @AppStorage("selectedCurrency") var selectedCurrency: String = "$"
    let availableCurrencies = ["$", "€", "₹", "£", "¥"]
    
    func login() {
        Task {
            do {
                try await SupabaseAuthService.shared.signIn(email: email, password: password)

                isLoggedIn = true
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
            } catch {
                errorMessage = "Logout failed: \(error.localizedDescription)"
            }
        }
    }
    
    func addExpense(category: String, amount: Double, date: Date, iconName: String) {
            let newExpense = Expense(id: UUID(), category: category, amount: amount, date: date, iconName: iconName)
            expenses.append(newExpense)
        }

        func updateExpense(_ updatedExpense: Expense) {
            if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                expenses[index] = updatedExpense
            }
        }

        func deleteExpense(at offsets: IndexSet) {
            expenses.remove(atOffsets: offsets)
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
}
