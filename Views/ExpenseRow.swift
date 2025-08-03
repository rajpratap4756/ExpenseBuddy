import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let currencySymbol: String // <-- passed in

    var body: some View {
        let formattedAmount = String(format: "%.2f", expense.amount)
        let displayAmount = "\(currencySymbol)\(formattedAmount)"

        HStack {
            Image(systemName: expense.iconName)
                .resizable()
                .frame(width: 28, height: 28)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(expense.category)
                    .font(.headline)
                Text("\(expense.dateString)  •  \(expense.timeString)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(displayAmount)
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
