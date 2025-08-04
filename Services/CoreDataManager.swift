//
//  CoreDataManager.swift
//  ExpenseBuddy
//
//  Created by RajPratapSingh on 01/08/25.
//

import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseBuddy")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
                print(" Core Data saved successfully")
            } catch {
                print(" Core Data save failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Expense Operations
    func saveExpenseToLocal(_ expense: Expense) {
        let entity = ExpenseEntity(context: context)
        entity.id = expense.id.uuidString
        entity.category = expense.category
        entity.amount = expense.amount
        entity.date = expense.date
        entity.iconName = expense.iconName
        entity.userId = expense.userId
        entity.createdAt = expense.createdAt
        entity.updatedAt = expense.updatedAt
        entity.syncStatus = false // Mark as needing sync
        
        save()
    }
    
    func updateExpenseInLocal(_ expense: Expense) {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id.uuidString)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.category = expense.category
                entity.amount = expense.amount
                entity.date = expense.date
                entity.iconName = expense.iconName
                entity.userId = expense.userId
                entity.updatedAt = expense.updatedAt
                entity.syncStatus = false
                save()
            }
        } catch {
            print("Failed to update expense in Core Data: \(error)")
        }
    }
    
    func deleteExpenseFromLocal(id: UUID) {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            save()
        } catch {
            print(" Failed to delete expense from Core Data: \(error)")
        }
    }
    
    func fetchLocalExpenses() -> [Expense] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let category = entity.category,
                      let date = entity.date else { return nil }
                
                return Expense(
                    id: UUID(uuidString: id) ?? UUID(),
                    category: category,
                    amount: entity.amount,
                    date: date,
                    iconName: entity.iconName ?? "creditcard",
                    userId: entity.userId ?? "",
                    createdAt: entity.createdAt ?? date,
                    updatedAt: entity.updatedAt ?? date
                )
            }
        } catch {
            print(" Failed to fetch local expenses: \(error)")
            return []
        }
    }
    
    func fetchUnsyncedExpenses() -> [Expense] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "syncStatus == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let category = entity.category,
                      let date = entity.date else { return nil }
                
                return Expense(
                    id: UUID(uuidString: id) ?? UUID(),
                    category: category,
                    amount: entity.amount,
                    date: date,
                    iconName: entity.iconName ?? "creditcard",
                    userId: entity.userId ?? "",
                    createdAt: entity.createdAt ?? date,
                    updatedAt: entity.updatedAt ?? date
                )
            }
        } catch {
            print(" Failed to fetch unsynced expenses: \(error)")
            return []
        }
    }
    
    func markExpenseAsSynced(id: UUID) {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.syncStatus = true
                save()
            }
        } catch {
            print(" Failed to mark expense as synced: \(error)")
        }
    }
    
    func clearAllLocalData() {
        let request: NSFetchRequest<NSFetchRequestResult> = ExpenseEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            save()
            print("All local data cleared")
        } catch {
            print(" Failed to clear local data: \(error)")
        }
    }
} 
