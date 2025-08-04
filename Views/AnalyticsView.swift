//
//  AnalyticsView.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import SwiftUI
import Charts

// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    let iconToCategory: [String: String] = [
        "fork.knife": "Food",
        "car": "Transport",
        "bag": "Shopping",
        "house": "Rent",
        "creditcard": "Other"
    ]
    
    // Dynamic color generator based on amount
    func colorForAmount(_ amount: Double, maxAmount: Double) -> Color {
        let percentage = maxAmount > 0 ? amount / maxAmount : 0
        let hue = 0.6 + (percentage * 0.3) // Blue to Purple range
        let saturation = 0.7 + (percentage * 0.3) // More vibrant for higher amounts
        let brightness = 0.8 - (percentage * 0.2) // Slightly darker for higher amounts
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    // Category colors with dynamic intensity
    func colorForCategory(_ category: String, amount: Double, maxAmount: Double) -> Color {
        let baseColors: [String: Color] = [
            "Food": .orange,
            "Transport": .blue,
            "Shopping": .green,
            "Rent": .purple,
            "Other": .gray
        ]
        
        let baseColor = baseColors[category] ?? .gray
        let percentage = maxAmount > 0 ? amount / maxAmount : 0
        
        // Adjust saturation and brightness based on amount
        let adjustedColor = baseColor.opacity(0.6 + (percentage * 0.4))
        return adjustedColor
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Analytics")
                    .font(.title2)
                    .bold()

                // Monthly Overview (Bar Chart)
                VStack(alignment: .leading) {
                    Text("Monthly Overview")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Chart {
                        ForEach(authVM.expensesGroupedByMonth(), id: \.key) { month, total in
                            let maxAmount = authVM.expensesGroupedByMonth().map { $0.value }.max() ?? 1
                            BarMark(
                                x: .value("Month", month),
                                y: .value("Total", total)
                            )
                            .foregroundStyle(colorForAmount(total, maxAmount: maxAmount))
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(16)

                // Expense by Category (Pie Chart)
                VStack(alignment: .leading) {
                    Text("Expense by Category")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Chart {
                        ForEach(authVM.expensesGroupedByIcon(), id: \.iconName) { item in
                            let categoryLabel = iconToCategory[item.iconName] ?? item.iconName
                            let maxAmount = authVM.expensesGroupedByIcon().map { $0.total }.max() ?? 1
                            SectorMark(
                                angle: .value("Amount", item.total),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(colorForCategory(categoryLabel, amount: item.total, maxAmount: maxAmount))
                        }
                    }
                    .frame(height: 180)
                    
                    // Category Legend
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(authVM.expensesGroupedByIcon(), id: \.iconName) { item in
                            let categoryLabel = iconToCategory[item.iconName] ?? item.iconName
                            let maxAmount = authVM.expensesGroupedByIcon().map { $0.total }.max() ?? 1
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(colorForCategory(categoryLabel, amount: item.total, maxAmount: maxAmount))
                                    .frame(width: 12, height: 12)
                                Text(categoryLabel)
                                    .font(.caption)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(16)

                // Summary Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    SummaryCard(title: "Total Expenses", value: authVM.formatCurrency(authVM.filteredExpenses.reduce(0) { $0 + $1.amount }))
                    SummaryCard(title: "Average Daily", value: authVM.formatCurrency(authVM.averageDailyExpense()))
                    SummaryCard(title: "Highest Expense", value: authVM.formatCurrency(authVM.highestExpense()))
                    SummaryCard(title: "Lowest Expense", value: authVM.formatCurrency(authVM.lowestExpense()))
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Analytics")
    }
}

// MARK: - Summary Card View
struct SummaryCard: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.purple.opacity(0.2))
        .cornerRadius(12)
    }
}
