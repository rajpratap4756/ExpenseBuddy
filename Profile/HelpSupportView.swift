import SwiftUI

struct HelpSupportView: View {
    @State private var searchQuery = ""

    var body: some View {
        ZStack {
            // Background Color
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            List {
                Section {
                    TextField("Search help articles", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .listRowBackground(Color.clear)

                Section(header: Text("COMMON TOPICS")) {
                    NavigationLink(destination: Text("Learn how to track your daily expenses")) {
                        VStack(alignment: .leading) {
                            Text("Getting Started")
                                .font(.headline)
                            Text("Learn the basics of ExpenseBuddy")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    NavigationLink(destination: Text("Detailed guide on managing categories")) {
                        VStack(alignment: .leading) {
                            Text("Managing Categories")
                                .font(.headline)
                            Text("Organize your expenses effectively")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    NavigationLink(destination: Text("Learn about reports and analytics")) {
                        VStack(alignment: .leading) {
                            Text("Reports & Analytics")
                                .font(.headline)
                            Text("Understanding your spending patterns")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.clear)

                Section(header: Text("CONTACT SUPPORT")) {
                    Button(action: {
                        // Handle email support
                    }) {
                        Label("Email Support", systemImage: "envelope")
                    }

                    Button(action: {
                        // Handle chat support
                    }) {
                        Label("Live Chat", systemImage: "message")
                    }

                    Link(destination: URL(string: "https://expensebuddy.com/faq")!) {
                        Label("FAQ", systemImage: "questionmark.circle")
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden) // Hide default background
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}
