//
//  AnalyticsView.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    let iconToCategory: [String: String] = [
        "fork.knife": "Food",
        "car": "Transport",
        "bag": "Shopping",
        "house": "Rent",
        "creditcard": "Other"
    ]

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
                            BarMark(
                                x: .value("Month", month),
                                y: .value("Total", total)
                            )
                            .foregroundStyle(Color.blue)
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Expense by Category (Pie Chart)
                VStack(alignment: .leading) {
                    Text("Expense by Category")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Chart {
                        ForEach(authVM.expensesGroupedByIcon(), id: \.iconName) { item in
                            let categoryLabel = iconToCategory[item.iconName] ?? item.iconName
                            SectorMark(
                                angle: .value("Amount", item.total),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Category", categoryLabel))
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Summary Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    SummaryCard(title: "Total Expenses", value: String(format: "%.2f", authVM.totalAmount()))
                    SummaryCard(title: "Average Daily", value: String(format: "%.2f", authVM.averageDailyExpense()))
                    SummaryCard(title: "Highest Expense", value: String(format: "%.2f", authVM.highestExpense()))
                    SummaryCard(title: "Lowest Expense", value: String(format: "%.2f", authVM.lowestExpense()))

                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }
}

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
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

