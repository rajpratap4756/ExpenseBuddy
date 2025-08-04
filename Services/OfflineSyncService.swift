//
//  OfflineSyncService.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import Foundation
import Network
import Combine

class OfflineSyncService: ObservableObject {
    static let shared = OfflineSyncService()
    
    @Published var isOnline = true
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let networkMonitor = NWPathMonitor()
    private let coreDataManager = CoreDataManager.shared
    private let expenseService = ExpenseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // --- Profile Sync Queue ---
    private var pendingProfile: Profile? = nil
    
    private init() {
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        // Set initial network status
        let initialPath = networkMonitor.currentPath
        isOnline = initialPath.status == .satisfied
        print("🌐 Initial network status: \(isOnline ? "Online" : "Offline")")
        
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasOffline = !(self?.isOnline ?? true)
                let newStatus = path.status == .satisfied
                self?.isOnline = newStatus
                let isNowOnline = self?.isOnline ?? false
                
                print("🌐 Network status changed: \(wasOffline ? "Offline" : "Online") -> \(isNowOnline ? "Online" : "Offline")")
                print("🌐 Path status: \(path.status)")
                print("🌐 Path is satisfied: \(path.status == .satisfied)")
                print("🌐 New status: \(newStatus ? "Online" : "Offline")")
                
                // Force UI update by triggering objectWillChange
                self?.objectWillChange.send()
                
                // If we just came back online, retry pending syncs
                if wasOffline && isNowOnline {
                    print("🔄 Network restored - triggering sync retry")
                    Task {
                        await self?.retryPendingProfileSync()
                        await self?.performSync()
                    }
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    // MARK: - Profile Sync
    func queueProfileForSync(_ profile: Profile) {
        pendingProfile = profile
        print("📝 Profile queued for sync: \(profile.email)")
    }
    
    private func retryPendingProfileSync() async {
        guard let profile = pendingProfile else { 
            print("📝 No pending profile to sync")
            return 
        }
        
        print("🔄 Attempting to sync queued profile...")
        do {
            // Try to create profile, but if it fails due to duplicate, try to fetch existing
            do {
                _ = try await ProfileService.shared.createProfile(profile)
                pendingProfile = nil
                print("✅ Profile synced successfully after network restored")
            } catch {
                // If creation fails due to duplicate, try to fetch the existing profile
                if error.localizedDescription.contains("duplicate") {
                    print("📝 Profile already exists, fetching existing profile...")
                    let existingProfile = try await ProfileService.shared.fetchProfile(for: profile.id)
                    print("✅ Existing profile found: \(existingProfile.fullName)")
                    pendingProfile = nil
                } else {
                    throw error
                }
            }
        } catch {
            print("❌ Still failed to sync profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sync Operations
    func syncWhenOnline() {
        guard isOnline && !isSyncing else { return }
        
        Task {
            await performSync()
        }
    }
    
    @MainActor
    func performSync() async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString else {
            print("❌ No user ID available for sync")
            return
        }
        
        isSyncing = true
        syncError = nil
        
        print("🔄 Starting offline sync...")
        
        // 1. Upload local changes to server
        await uploadLocalChanges(userId: userId)
        
        // 2. Download server changes to local
        await downloadServerChanges(userId: userId)
        
        // 3. Update sync status
        lastSyncDate = Date()
        print("✅ Offline sync completed successfully")
        
        isSyncing = false
    }
    
    // MARK: - Upload Local Changes
    private func uploadLocalChanges(userId: String) async {
        let unsyncedExpenses = coreDataManager.fetchUnsyncedExpenses()
        
        for expense in unsyncedExpenses {
            do {
                // Create a new expense with proper userId
                var expenseToUpload = expense
                expenseToUpload.userId = userId
                
                let uploadedExpense = try await expenseService.createExpense(expenseToUpload)
                coreDataManager.markExpenseAsSynced(id: uploadedExpense.id)
                print("✅ Uploaded expense: \(expense.category) - \(expense.amount)")
                
            } catch {
                print("❌ Failed to upload expense: \(error.localizedDescription)")
                // Don't mark as synced if upload failed
            }
        }
    }
    
    // MARK: - Download Server Changes
    private func downloadServerChanges(userId: String) async {
        do {
            let serverExpenses = try await expenseService.fetchExpenses(for: userId)
            let localExpenses = coreDataManager.fetchLocalExpenses()
            
            // Find new expenses from server
            let newExpenses = serverExpenses.filter { serverExpense in
                !localExpenses.contains { localExpense in
                    localExpense.id == serverExpense.id
                }
            }
            
            // Save new expenses to local storage
            for expense in newExpenses {
                coreDataManager.saveExpenseToLocal(expense)
                coreDataManager.markExpenseAsSynced(id: expense.id)
                print("✅ Downloaded expense: \(expense.category) - \(expense.amount)")
            }
            
        } catch {
            print("❌ Failed to download server changes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Manual Sync
    func manualSync() async {
        // Force check network status
        await checkNetworkStatus()
        
        guard isOnline else {
            syncError = "No internet connection available"
            return
        }
        
        await performSync()
    }
    
    // MARK: - Force Network Status Update
    @MainActor
    func forceNetworkStatusUpdate() {
        let currentPath = networkMonitor.currentPath
        let newStatus = currentPath.status == .satisfied
        
        print("🔄 Force updating network status: \(isOnline ? "Online" : "Offline") -> \(newStatus ? "Online" : "Offline")")
        print("🔄 Current path status: \(currentPath.status)")
        print("🔄 Path is satisfied: \(currentPath.status == .satisfied)")
        print("🔄 Available interfaces: \(currentPath.availableInterfaces)")
        
        isOnline = newStatus
        objectWillChange.send()
    }
    
    // MARK: - Check Network Status
    @MainActor
    func checkNetworkStatus() async {
        let currentPath = networkMonitor.currentPath
        let newStatus = currentPath.status == .satisfied
        
        if isOnline != newStatus {
            print("🌐 Network status updated: \(isOnline ? "Online" : "Offline") -> \(newStatus ? "Online" : "Offline")")
            isOnline = newStatus
            // Force UI update
            objectWillChange.send()
        }
        
        print("🌐 Current network status: \(isOnline ? "Online" : "Offline")")
        print("🌐 Path status: \(currentPath.status)")
    }
    
    // MARK: - Sync Local to Remote
    private func syncLocalToRemote() async {
        let unsyncedExpenses = coreDataManager.fetchUnsyncedExpenses()
        
        for expense in unsyncedExpenses {
            do {
                let uploadedExpense = try await expenseService.createExpense(expense)
                coreDataManager.markExpenseAsSynced(id: uploadedExpense.id)
                print("✅ Uploaded expense: \(expense.category) - \(expense.amount)")
            } catch {
                print("❌ Failed to upload expense: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Sync Remote to Local
    private func syncRemoteToLocal() async {
        guard let userId = SupabaseAuthService.shared.currentUser?.id.uuidString else { return }
        
        do {
            let serverExpenses = try await expenseService.fetchExpenses(for: userId)
            let localExpenses = coreDataManager.fetchLocalExpenses()
            
            // Find new expenses from server
            let newExpenses = serverExpenses.filter { serverExpense in
                !localExpenses.contains { localExpense in
                    localExpense.id == serverExpense.id
                }
            }
            
            // Save new expenses to local storage
            for expense in newExpenses {
                coreDataManager.saveExpenseToLocal(expense)
                coreDataManager.markExpenseAsSynced(id: expense.id)
                print("✅ Downloaded expense: \(expense.category) - \(expense.amount)")
            }
        } catch {
            print("❌ Failed to download server changes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Offline-First Operations
    func addExpenseOffline(category: String, amount: Double, date: Date, iconName: String) -> Expense {
        let expense = Expense(
            category: category,
            amount: amount,
            date: date,
            iconName: iconName,
            userId: SupabaseAuthService.shared.currentUser?.id.uuidString ?? ""
        )
        
        // Save to local storage immediately
        coreDataManager.saveExpenseToLocal(expense)
        
        // Try to sync if online
        if isOnline {
            Task {
                await performSync()
            }
        }
        
        return expense
    }
    
    func updateExpenseOffline(_ expense: Expense) {
        // Update local storage immediately
        coreDataManager.updateExpenseInLocal(expense)
        
        // Try to sync if online
        if isOnline {
            Task {
                await performSync()
            }
        }
    }
    
    func deleteExpenseOffline(id: UUID) {
        // Delete from local storage immediately
        coreDataManager.deleteExpenseFromLocal(id: id)
        
        // Try to sync if online
        if isOnline {
            Task {
                await performSync()
            }
        }
    }
    
    // MARK: - Data Loading
    func loadExpensesOffline() -> [Expense] {
        return coreDataManager.fetchLocalExpenses()
    }
    
    // MARK: - Network Testing
    @MainActor
    func testNetworkConnectivity() async {
        print("🧪 Testing network connectivity...")
        
        let currentPath = networkMonitor.currentPath
        print("🧪 Path status: \(currentPath.status)")
        print("🧪 Path is satisfied: \(currentPath.status == .satisfied)")
        print("🧪 Available interfaces: \(currentPath.availableInterfaces)")
        
        // Try a simple network request to test connectivity
        do {
            let url = URL(string: "https://www.apple.com")!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🧪 Network test successful: Status \(httpResponse.statusCode)")
                // Force update to online if test succeeds
                if !isOnline {
                    print("🧪 Forcing status to Online based on successful network test")
                    isOnline = true
                    objectWillChange.send()
                }
            }
        } catch {
            print("🧪 Network test failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        networkMonitor.cancel()
    }
}

    // MARK: - Network Status Extension
    extension OfflineSyncService {
        var networkStatusText: String {
            if isSyncing {
                return "Syncing..."
            } else if !isOnline {
                return "Offline"
            } else if syncError != nil {
                return "Sync Error"
            } else if pendingProfile != nil {
                return "Pending Sync"
            } else {
                return "Online"
            }
        }
        
        var lastSyncText: String {
            guard let lastSync = lastSyncDate else {
                return "Never synced"
            }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return "Last sync: \(formatter.string(from: lastSync))"
        }
        
        var syncStatusColorName: String {
            if isSyncing {
                return "blue"
            } else if !isOnline {
                return "red"
            } else if syncError != nil {
                return "orange"
            } else if pendingProfile != nil {
                return "yellow"
            } else {
                return "green"
            }
        }
    } 