//
//  DataModel.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//


import Foundation

struct Expense: Identifiable, Equatable {
    let id: UUID
    var category: String
    var amount: Double
    var date: Date
    var iconName: String


    init(category: String, amount: Double, date: Date, iconName: String) {
            self.id = UUID()
            self.category = category
            self.amount = amount
            self.date = date
            self.iconName = iconName
        }

        // Init for editing existing expense with same id
        init(id: UUID, category: String, amount: Double, date: Date, iconName: String) {
            self.id = id
            self.category = category
            self.amount = amount
            self.date = date
            self.iconName = iconName
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
        Expense(category: "Food", amount: 45.5, date: Date(), iconName: "fork.knife"),
        Expense(category: "Transport", amount: 32.0, date: Date(), iconName: "car"),
        Expense(category: "Shopping", amount: 128.99, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, iconName: "bag"),
        Expense(category: "Rent", amount: 1200.0, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, iconName: "house"),
    ]
}


