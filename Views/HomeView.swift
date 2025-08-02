//import SwiftUI
//
//struct HomeView: View {
//    @StateObject private var authVM = AuthViewModel()
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Text("Welcome, \(authVM.email)!")
//                    .font(.title.bold())
//                    .padding()
//                
//                // Add your home screen content here
//                
//                Button(action: {
//                    Task {
//                        do {
//                            await authVM.logout()
//                            dismiss()
//                        } catch {
//                            // Error is handled in AuthViewModel
//                        }
//                    }
//                }) {
//                    Text("Logout")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//            }
//            .navigationBarTitle("ExpenseBuddy", displayMode: .large)
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//}
import SwiftUI

struct HomeView: View {
    @StateObject private var authVM = AuthViewModel()
    @State private var showAddExpense = false
    @State private var showEditExpense: Expense?
    @State private var showProfile = false

    let filters = ["Day", "Week", "Month", "Year"]

    var body: some View {
        NavigationView {
            VStack {
                // Top Bar with Profile Button on Right
                HStack {
                    Spacer()
                    NavigationLink(destination: ProfileView(viewModel: authVM)) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal)

                // Welcome Text
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("John Doe")
                            .font(.title3)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Total Expenses Card
                NavigationLink(destination: AnalyticsView(viewModel: authVM)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Expenses")
                            .foregroundColor(.white)
                            .font(.subheadline)

                        Text("$\(String(format: "%.2f", authVM.totalAmount()))")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                            Text("$\(String(format: "%.2f", authVM.previousPeriodTotal())) last \(authVM.selectedFilter.lowercased())")
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
                        ExpenseRow(expense: expense)
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
    }
}
