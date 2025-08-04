//
//  TestView.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔍 Debug Information")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Login Status: \(authVM.isLoggedIn ? "✅ Logged In" : "❌ Not Logged In")")
                            .font(.subheadline)
                        
                        if let user = SupabaseAuthService.shared.currentUser {
                            Text("User ID: \(user.id.uuidString)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Email: \(user.email ?? "No email")")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("No current user")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Profile Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("👤 Profile Data")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if let profile = authVM.userProfile {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Name: \(profile.fullName)")
                            Text("Email: \(profile.email)")
                            Text("Currency: \(profile.currency)")
                            Text("Timezone: \(profile.timezone)")
                        }
                        .font(.subheadline)
                    } else {
                        Text("No profile data loaded")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Expenses Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("💰 Expenses Data")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total Expenses: \(authVM.expenses.count)")
                        Text("Filtered Expenses: \(authVM.filteredExpenses.count)")
                        Text("Selected Filter: \(authVM.selectedFilter)")
                        Text("Total Amount: \(authVM.totalAmount())")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                
                // Error Section
                if let errorMessage = authVM.errorMessage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("❌ Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Loading Status
                if authVM.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 15) {
                    if authVM.isLoggedIn {
                        Button("🚪 Logout") {
                            authVM.logout()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        
                        Button("🔄 Refresh Data") {
                            Task {
                                await authVM.loadUserData()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        
                        Button("🧪 Test Supabase") {
                            Task {
                                await authVM.testSupabaseConnection()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        
                        Button("🔍 Debug User & Expenses") {
                            Task {
                                await authVM.debugUserAndExpenses()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                    } else {
                        Button("🔐 Go to Login") {
                            // This would typically navigate to login
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Debug Test")
        }
    }
} 