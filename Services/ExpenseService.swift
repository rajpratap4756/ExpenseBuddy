//
//  ExpenseService.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import Foundation
import Supabase

final class ExpenseService: ObservableObject {
    static let shared = ExpenseService()
    
    private let client = SupabaseAuthService.shared.client
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Create Expense
    func createExpense(_ expense: Expense) async throws -> Expense {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        
        struct ExpenseInsert: Codable {
            let id: String
            let category: String
            let amount: Double
            let date: String
            let icon_name: String
            let user_id: String
            let created_at: String
            let updated_at: String
        }
        
        let expenseInsert = ExpenseInsert(
            id: expense.id.uuidString,
            category: expense.category,
            amount: expense.amount,
            date: dateFormatter.string(from: expense.date),
            icon_name: expense.iconName,
            user_id: expense.userId,
            created_at: dateFormatter.string(from: expense.createdAt),
            updated_at: dateFormatter.string(from: expense.updatedAt)
        )
        
        do {
            let response: ExpenseResponse = try await client
                .from("expenses")
                .insert(expenseInsert)
                .select()
                .single()
                .execute()
                .value
            
            return response.toExpense()
        } catch {
            errorMessage = "Failed to create expense: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Read Expenses
    func fetchExpenses(for userId: String) async throws -> [Expense] {
        print(" Fetching expenses for user ID: \(userId)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            print(" Executing Supabase query for expenses table...")
            let response: [ExpenseResponse] = try await client
                .from("expenses")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            let expenses = response.map { $0.toExpense() }
            print(" Fetched \(expenses.count) expenses for user ID \(userId)")
            return expenses
        } catch {
            print(" Failed to fetch expenses: \(error.localizedDescription)")
            print("Full error: \(error)")
            errorMessage = "Failed to fetch expenses: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchExpensesByEmail(email: String) async throws -> [Expense] {
        print("Fetching expenses for email: \(email)")
        isLoading = true
        defer { isLoading = false }
        
        do {
            print(" Executing Supabase query for expenses by email...")
            let response: [ExpenseResponse] = try await client
                .from("expenses")
                .select("*, profiles!inner(email)")
                .eq("profiles.email", value: email)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            let expenses = response.map { $0.toExpense() }
            print(" Fetched \(expenses.count) expenses for email \(email)")
            return expenses
        } catch {
            print(" Failed to fetch expenses by email: \(error.localizedDescription)")
            print(" Full error: \(error)")
            errorMessage = "Failed to fetch expenses by email: \(error.localizedDescription)"
            throw error
        }
    }
    
    func fetchExpense(by id: UUID) async throws -> Expense {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: ExpenseResponse = try await client
                .from("expenses")
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
            
            return response.toExpense()
        } catch {
            errorMessage = "Failed to fetch expense: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Update Expense
    func updateExpense(_ expense: Expense) async throws -> Expense {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        let updatedAt = Date()
        
        struct ExpenseUpdate: Codable {
            let category: String
            let amount: Double
            let date: String
            let icon_name: String
            let updated_at: String
        }
        
        let expenseUpdate = ExpenseUpdate(
            category: expense.category,
            amount: expense.amount,
            date: dateFormatter.string(from: expense.date),
            icon_name: expense.iconName,
            updated_at: dateFormatter.string(from: updatedAt)
        )
        
        do {
            let response: ExpenseResponse = try await client
                .from("expenses")
                .update(expenseUpdate)
                .eq("id", value: expense.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            return response.toExpense()
        } catch {
            errorMessage = "Failed to update expense: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Delete Expense
    func deleteExpense(id: UUID) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client
                .from("expenses")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            errorMessage = "Failed to delete expense: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Filter Expenses
    func fetchExpensesByDateRange(userId: String, startDate: Date, endDate: Date) async throws -> [Expense] {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        
        do {
            let response: [ExpenseResponse] = try await client
                .from("expenses")
                .select()
                .eq("user_id", value: userId)
                .gte("date", value: dateFormatter.string(from: startDate))
                .lte("date", value: dateFormatter.string(from: endDate))
                .order("date", ascending: false)
                .execute()
                .value
            
            return response.map { $0.toExpense() }
        } catch {
            errorMessage = "Failed to fetch expenses by date range: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Get Total Expenses
    func getTotalExpenses(userId: String, startDate: Date? = nil, endDate: Date? = nil) async throws -> Double {
        isLoading = true
        defer { isLoading = false }
        
        var query = client
            .from("expenses")
            .select("amount")
            .eq("user_id", value: userId)
        
        if let startDate = startDate, let endDate = endDate {
            let dateFormatter = ISO8601DateFormatter()
            query = query
                .gte("date", value: dateFormatter.string(from: startDate))
                .lte("date", value: dateFormatter.string(from: endDate))
        }
        
        do {
            let response: [ExpenseResponse] = try await query.execute().value
            return response.reduce(0) { $0 + $1.amount }
        } catch {
            errorMessage = "Failed to get total expenses: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Get Expenses by Category
    func getExpensesByCategory(userId: String) async throws -> [String: Double] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response: [ExpenseResponse] = try await client
                .from("expenses")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            let expenses = response.map { $0.toExpense() }
            let grouped = Dictionary(grouping: expenses) { $0.category }
            return grouped.mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
        } catch {
            errorMessage = "Failed to get expenses by category: \(error.localizedDescription)"
            throw error
        }
    }
} 
