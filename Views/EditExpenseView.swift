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
            Form {
                TextField("Category", text: $category)
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                Picker("Icon", selection: $iconName) {
                    Label("Food", systemImage: "fork.knife").tag("fork.knife")
                    Label("Transport", systemImage: "car").tag("car")
                    Label("Shopping", systemImage: "bag").tag("bag")
                    Label("Rent", systemImage: "house").tag("house")
                }
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedExpense = Expense(
                            id: originalExpense.id, // retain original ID
                            category: category,
                            amount: amount,
                            date: date,
                            iconName: iconName
                        )
                        viewModel.updateExpense(updatedExpense)
                        viewModel.filterExpenses(by: viewModel.selectedFilter)
                        dismiss()
                    }
                }
            }
        }
    }
}
