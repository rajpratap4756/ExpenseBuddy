import SwiftUI

struct AboutView: View {
    let appVersion = "1.0.0"
    let buildNumber = "100"
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#d6e4ff"), Color(hex: "#fbe0f8")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Main list
            List {
                Section {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ExpenseBuddy")
                                .font(.title2)
                                .bold()
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("ABOUT")) {
                    Text("ExpenseBuddy is your personal finance companion, helping you track expenses and manage your budget effectively. Our mission is to make financial management simple and accessible for everyone.")
                        .font(.body)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("LEGAL")) {
                    NavigationLink(destination: Text("Terms of Service content")) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: Text("Privacy Policy content")) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("License information")) {
                        Label("Licenses", systemImage: "doc.badge.gearshape")
                    }
                }
                
                Section(header: Text("CREDITS")) {
                    Link(destination: URL(string: "https://github.com/expensebuddy")!) {
                        Label("GitHub Repository", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    
                    Text("© 2023 ExpenseBuddy. All rights reserved.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                }
            }
            .scrollContentBackground(.hidden) // Hides default List background
            .background(Color.clear)
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
