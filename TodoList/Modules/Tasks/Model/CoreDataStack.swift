//
//  CoreDataStack.swift
//  TodoList
//
//  Created by Jayant Karthic on 16/07/24.
//

import CoreData
import UIKit

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var persistentContainer: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        return appDelegate.persistentContainer
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
