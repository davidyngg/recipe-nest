//
//  PersistenceController.swift
//
//
//  Created by David Yang on 8/7/26.
//

import CoreData

// Owns the CoreData stack. Access the database through
// PersistenceController.shared.container.viewContext.
final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        // The name must match the model file ("Model.xcdatamodeld").
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        // Keep the main context in sync with any background writes.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Saves the view context if there are uncommitted changes.
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Core Data save failed: \(error)")
        }
    }
}
