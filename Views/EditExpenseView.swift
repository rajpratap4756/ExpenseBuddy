import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AuthViewModel
    var originalExpense: Expense

    @State private var category: String
    @State private var amount: Double
    @State private var date: Date
    @State private var iconName: String

    init(viewModel: AuthViewModel, expense: Expense) {
        self.viewModel = viewModel
        self.originalExpense = expense
        _category = State(initialValue: expense.category)
        _amount = State(initialValue: expense.amount)
        _date = State(initialValue: expense.date)
        _iconName = State(initialValue: expense.iconName)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Section Header
                        Text("Edit Expense Info")
                            .font(.headline)
                            .padding(.top, 16)

                        VStack(spacing: 15) {
                            TextField("Category", text: $category)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)

                            TextField("Amount", value: $amount, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)

                            DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)

                            Picker("Category", selection: $iconName) {
                                Label("Food", systemImage: "fork.knife").tag("fork.knife")
                                Label("Transport", systemImage: "car").tag("car")
                                Label("Shopping", systemImage: "bag").tag("bag")
                                Label("Rent", systemImage: "house").tag("house")
                                Label("Other", systemImage: "creditcard").tag("creditcard")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        // 💾 Save Button
                        Button(action: {
                            let updatedExpense = Expense(
                                id: originalExpense.id,
                                category: category,
                                amount: amount,
                                date: date,
                                iconName: iconName,
                                userId: originalExpense.userId,
                                createdAt: originalExpense.createdAt,
                                updatedAt: originalExpense.updatedAt
                            )
                            viewModel.updateExpense(updatedExpense)
                            viewModel.filterExpenses(by: viewModel.selectedFilter)
                            dismiss()
                        }) {
                            Text("Save Expense")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#3b82f6"), Color(hex: "#a855f7")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // ❌ Cancel Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .padding()
                        }

                        Spacer()
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Expense")
        }
    }
}
