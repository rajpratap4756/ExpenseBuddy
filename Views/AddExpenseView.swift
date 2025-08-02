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
            Form {
                Section(header: Text("Expense Info")) {
                    TextField("Title", text: $category)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Category", selection: $iconName) {
                        Label("Food", systemImage: "fork.knife").tag("fork.knife")
                        Label("Transport", systemImage: "car").tag("car")
                        Label("Shopping", systemImage: "bag").tag("bag")
                        Label("Rent", systemImage: "house").tag("house")
                        Label("Other", systemImage: "creditcard").tag("creditcard")

                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountDouble = Double(amount), !category.isEmpty {
                            viewModel.addExpense(category: category, amount: amountDouble, date: date, iconName: iconName)
                            viewModel.filterExpenses(by: viewModel.selectedFilter)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
