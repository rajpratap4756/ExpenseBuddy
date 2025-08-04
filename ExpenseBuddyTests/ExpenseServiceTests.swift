//
//  ExpenseServiceTests.swift
//  ExpenseBuddyTests
//
//  Created by RajPratapSingh on 01/08/25.
//

import XCTest
@testable import ExpenseBuddy

final class ExpenseServiceTests: XCTestCase {
    
    var expenseService: ExpenseService!
    
    override func setUpWithError() throws {
        expenseService = ExpenseService.shared
    }
    
    override func tearDownWithError() throws {
        expenseService = nil
    }
    
    func testExpenseCreation() throws {
        // This test would require a mock Supabase client
        // For now, we'll test the model creation
        let expense = Expense(
            category: "Food",
            amount: 25.50,
            date: Date(),
            iconName: "fork.knife",
            userId: "test-user-id"
        )
        
        XCTAssertEqual(expense.category, "Food")
        XCTAssertEqual(expense.amount, 25.50)
        XCTAssertEqual(expense.iconName, "fork.knife")
        XCTAssertEqual(expense.userId, "test-user-id")
    }
    
    func testExpenseResponseConversion() throws {
        let dateFormatter = ISO8601DateFormatter()
        let now = Date()
        
        let response = ExpenseResponse(
            id: "test-id",
            category: "Transport",
            amount: 15.75,
            date: dateFormatter.string(from: now),
            iconName: "car",
            userId: "test-user-id",
            createdAt: dateFormatter.string(from: now),
            updatedAt: dateFormatter.string(from: now)
        )
        
        let expense = response.toExpense()
        
        XCTAssertEqual(expense.category, "Transport")
        XCTAssertEqual(expense.amount, 15.75)
        XCTAssertEqual(expense.iconName, "car")
        XCTAssertEqual(expense.userId, "test-user-id")
    }
    
    func testProfileCreation() throws {
        let profile = Profile(
            id: "test-user-id",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            phoneNumber: "+1234567890",
            currency: "$",
            timezone: "UTC"
        )
        
        XCTAssertEqual(profile.id, "test-user-id")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.firstName, "John")
        XCTAssertEqual(profile.lastName, "Doe")
        XCTAssertEqual(profile.fullName, "John Doe")
        XCTAssertEqual(profile.displayName, "John D.")
    }
    
    func testProfileResponseConversion() throws {
        let dateFormatter = ISO8601DateFormatter()
        let now = Date()
        
        let response = ProfileResponse(
            id: "test-user-id",
            email: "test@example.com",
            firstName: "Jane",
            lastName: "Smith",
            phoneNumber: "+1234567890",
            dateOfBirth: dateFormatter.string(from: now),
            profileImageUrl: "https://example.com/image.jpg",
            currency: "€",
            timezone: "UTC",
            createdAt: dateFormatter.string(from: now),
            updatedAt: dateFormatter.string(from: now)
        )
        
        let profile = response.toProfile()
        
        XCTAssertEqual(profile.id, "test-user-id")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.firstName, "Jane")
        XCTAssertEqual(profile.lastName, "Smith")
        XCTAssertEqual(profile.currency, "€")
        XCTAssertEqual(profile.timezone, "UTC")
    }
} 