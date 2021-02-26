//
//  File.swift
//  
//
//  Created by Telman Rustam on 2021-02-25.
//

import Foundation
import CoreData

extension CRUD{
    
    
    /// Fetch NSManagedObject
    /// - Parameters:
    ///   - entity: entity name
    /// - Returns: an array of NSManagedObject
    public func get(entity : String) ->[NSManagedObject]?  {
        return self.get(entity: entity, predicate: nil, args: nil, relation: nil, sort: nil)
    }
    
    
    /// Fetch NSManagedObject
    /// - Parameters:
    ///   - entity: entity name
    ///   - predicate: predicate to apply filters or where clause, for example: predicate: "type = %@ and archived = %@",
    ///   - args: args is used with predicate:  predicate: "type = %@ and archived = %@", args: [type, 0]
    ///   - sort: sort by
    /// - Returns: an array of NSManagedObject
    public func get(entity : String,  predicate : String?, args : [Any]?, sort: [(String,Bool)]?) ->[NSManagedObject]?  {
        return self.get(entity: entity, predicate: predicate, args: args, relation: nil, sort: sort)
    }
    
    
    /// Fetch NSManagedObject
    /// - Parameters:
    ///   - entity: entity name
    ///   - predicate: predicate to apply filters or where clause, for example: predicate: "type = %@ and archived = %@",
    ///   - args: args is used with predicate:  predicate: "type = %@ and archived = %@", args: [type, 0]
    ///   - relation: relation The relationship key paths to prefetch along with the entity for the request.
    ///   - sort: sort by
    /// - Returns: an array of NSManagedObject
    public func get(entity : String,  predicate : String?, args : [Any]?, relation : [String]?, sort: [(String,Bool)]?) ->[NSManagedObject]?  {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let predicateFormat = predicate, let predicateArgs = args{
            fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: predicateArgs)
        }
        
        if let relationshipKeyPaths = relation{
            fetchRequest.relationshipKeyPathsForPrefetching = relationshipKeyPaths
            
        }
        if let sortItems = sort{
            var sortDescriptors : [NSSortDescriptor] = []
            for item in sortItems{
                sortDescriptors.append(NSSortDescriptor(key: item.0, ascending: item.1))
            }
            fetchRequest.sortDescriptors = sortDescriptors
        }
        do {
            if let results = try self.managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] {
                let fetched: [NSManagedObject]? = results
                if fetched != nil {
                    return results
                }
                
            }
        }
        catch {
            fatalError("There was an error fetching the items")
        }
        return nil
    }
}
