//
//  DataManager.swift
//  Ten_Percent_Technical_
//
//  Created by Ethan Joseph on 1/9/23.
//

import Foundation
import CoreData
import UIKit

open class DataManager: NSObject {
    
    public static let shared = DataManager()
    
    private override init() {}

    /// Gets the current context
    private func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    
    func retrieveAppState() -> NSManagedObject? {
        guard let managedContext = getContext() else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AppState")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            if result.count > 0 {
                // Assuming there will only ever be one User in the app.
                return result[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            
            print("Retrieving app state failed. \(error)")
            return nil
        }
    }
    
    func saveAppState(_ state: AppStateStore) {
        guard let managedContext = getContext() else { return }
        
        let appState = retrieveAppState() ??
        NSEntityDescription.insertNewObject(forEntityName: "AppState", into: managedContext)
        
        //TODO: set the keys
        
        // Attempt to save
        
        do {
            print("Saving data")
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save data! \(error): \(error.userInfo)")
        }
    }
}
