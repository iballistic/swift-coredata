//
//  File.swift
//  
//
//  Created by Telman Rustam on 2021-02-25.
//

import Foundation
import CoreData

extension CRUD{
    
    public func delete(entity : String){
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let batchReq = NSBatchDeleteRequest(fetchRequest: fetchReq)
        do {
            try managedObjectContext?.execute(batchReq)
        }
        catch {
            print(error)
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - entity: table name
    ///   - predicateFormat: predicateFormat
    ///   - argumentArray: an array of arguments
    public func delete( entity : String, predicateFormat : String, argumentArray: [Any]?) {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray!)
        do {
            if let results = try managedObjectContext!.fetch(fetchRequest) as? [NSManagedObject] {
                print("Number of records \(String(describing: results.count))")
                for item in results{
                    managedObjectContext?.delete(item)
                }
            }
        }
        catch {
            fatalError("There was an error fetching the items")
        }
    }
}
