import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AuthViewModel

    @State private var category = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var iconName = "fork.knife"

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

                // 🧾 Form Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Section Header
                        Text("Expense Info")
                            .font(.headline)
                            .padding(.top, 16)

                        VStack(spacing: 15) {
                            TextField("Title", text: $category)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)

                            TextField("Amount", text: $amount)
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
                            if let amountDouble = Double(amount), !category.isEmpty {
                                viewModel.addExpense(category: category, amount: amountDouble, date: date, iconName: iconName)
                                viewModel.filterExpenses(by: viewModel.selectedFilter)
                                presentationMode.wrappedValue.dismiss()
                            }
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
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .padding()
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle("Add Expense")
        }
    }
}
