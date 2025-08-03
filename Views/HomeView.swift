import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showAddExpense = false
    @State private var showEditExpense: Expense?
    @State private var showProfile = false

    let filters = ["Day", "Week", "Month", "Year"]

    var body: some View {
        let totalAmount = authVM.totalAmount()
        let previousTotal = authVM.previousPeriodTotal()
        let period = authVM.selectedFilter.lowercased()

        return NavigationView {
            VStack {
                // Profile button at top-right
                HStack {
                    Spacer()
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal)

                // Welcome message
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("John Doe") // Optionally use authVM.user?.name
                            .font(.title3)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Total Expense Card
                NavigationLink(destination: AnalyticsView()) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Expenses")
                            .foregroundColor(.white)
                            .font(.subheadline)

                        Text(totalAmount)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                            Text("\(previousTotal) last \(period)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Filter Buttons
                HStack(spacing: 16) {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: {
                            authVM.filterExpenses(by: filter)
                        }) {
                            Text(filter)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 16)
                                .background(authVM.selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(authVM.selectedFilter == filter ? .white : .black)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.vertical)

                // Expenses List
                List {
                    ForEach(authVM.filteredExpenses) { expense in
                        ExpenseRow(expense: expense, currencySymbol: authVM.selectedCurrency)
                            .onTapGesture {
                                showEditExpense = expense
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = authVM.expenses.firstIndex(where: { $0.id == expense.id }) {
                                        authVM.deleteExpense(at: IndexSet(integer: index))
                                        authVM.filterExpenses(by: authVM.selectedFilter)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                    }
                }

                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.white)

                Spacer()
            }
            .sheet(item: $showEditExpense) { expense in
                EditExpenseView(viewModel: authVM, expense: expense)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(viewModel: authVM)
            }
            .overlay(
                Button(action: {
                    showAddExpense = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(),
                alignment: .bottomTrailing
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}
