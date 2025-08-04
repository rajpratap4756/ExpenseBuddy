//
//  DataModel.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import Foundation

// MARK: - Expense Model
struct Expense: Identifiable, Equatable, Codable {
    let id: UUID
    var category: String
    var amount: Double
    var date: Date
    var iconName: String
    var userId: String
    var createdAt: Date
    var updatedAt: Date

    init(category: String, amount: Double, date: Date, iconName: String, userId: String) {
        self.id = UUID()
        self.category = category
        self.amount = amount
        self.date = date
        self.iconName = iconName
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Init for editing existing expense with same id
    init(id: UUID, category: String, amount: Double, date: Date, iconName: String, userId: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.category = category
        self.amount = amount
        self.date = date
        self.iconName = iconName
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static let sampleData: [Expense] = [
        Expense(category: "Food", amount: 45.5, date: Date(), iconName: "fork.knife", userId: "sample-user"),
        Expense(category: "Transport", amount: 32.0, date: Date(), iconName: "car", userId: "sample-user"),
        Expense(category: "Shopping", amount: 128.99, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, iconName: "bag", userId: "sample-user"),
        Expense(category: "Rent", amount: 1200.0, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, iconName: "house", userId: "sample-user"),
    ]
}

// MARK: - Profile Model
struct Profile: Identifiable, Codable {
    let id: String
    var email: String
    var firstName: String
    var lastName: String
    var phoneNumber: String?
    var dateOfBirth: Date?
    var profileImageUrl: String?
    var currency: String
    var timezone: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, email: String, firstName: String, lastName: String, phoneNumber: String? = nil, dateOfBirth: Date? = nil, profileImageUrl: String? = nil, currency: String = "$", timezone: String = "UTC") {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.profileImageUrl = profileImageUrl
        self.currency = currency
        self.timezone = timezone
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var displayName: String {
        return "\(firstName) \(lastName.prefix(1))."
    }
}

// MARK: - Database Response Models
struct ExpenseResponse: Codable {
    let id: String
    let category: String
    let amount: Double
    let date: String
    let icon_name: String
    let user_id: String
    let created_at: String
    let updated_at: String
    
    func toExpense() -> Expense {
        let dateFormatter = ISO8601DateFormatter()
        return Expense(
            id: UUID(uuidString: id) ?? UUID(),
            category: category,
            amount: amount,
            date: dateFormatter.date(from: date) ?? Date(),
            iconName: icon_name,
            userId: user_id,
            createdAt: dateFormatter.date(from: created_at) ?? Date(),
            updatedAt: dateFormatter.date(from: updated_at) ?? Date()
        )
    }
}

struct ProfileResponse: Codable {
    let id: String
    let email: String
    let first_name: String
    let last_name: String
    let phone_number: String?
    let date_of_birth: String?
    let profile_image_url: String?
    let currency: String
    let timezone: String
    let created_at: String
    let updated_at: String
    
    func toProfile() -> Profile {
        let dateFormatter = ISO8601DateFormatter()
        return Profile(
            id: id,
            email: email,
            firstName: first_name,
            lastName: last_name,
            phoneNumber: phone_number,
            dateOfBirth: date_of_birth != nil ? dateFormatter.date(from: date_of_birth!) : nil,
            profileImageUrl: profile_image_url,
            currency: currency,
            timezone: timezone
        )
    }
}


