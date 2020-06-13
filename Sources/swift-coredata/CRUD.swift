//
//  CRUD.swift
//  swift-coredata
//
//  Created by Telman Rustam on 2020-06-13.
//  Copyright © 2020 Telman Rustam. All rights reserved.
//

import Foundation
import CoreData

open class CRUD{
    
    public var managedObjectContext : NSManagedObjectContext?
    
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
    public func initializeFetchedResultsController(entityName: String, predicate : String?) ->NSFetchedResultsController<NSFetchRequestResult>?{
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "attrkey", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: predicate!)
        fetchRequest.predicate = NSPredicate(format: predicate!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        //fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return fetchedResultsController
    }
    
    
    /// Save changes
    public func save(){
        if (self.managedObjectContext?.hasChanges)! {
            do {
                try self.managedObjectContext?.save()
            } catch {
                let nserror = error as NSError
                print("error: \(nserror)")
            }
        }
    }
    
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
    public func delete(entity : String,  predicateFormat : String, argumentArray: [Any]?) {
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
    
    //https://github.com/marcus-grant/HitList
    //https://www.raywenderlich.com/145809/getting-started-core-data-tutorial
    public func add(entity : String, keyValue: [String: Any]?)-> NSManagedObject? {
        let entity = NSEntityDescription.insertNewObject(forEntityName: entity, into: managedObjectContext!)
        guard let items = keyValue else{
            return nil
        }
        entity.setValuesForKeys(items)
        return entity
        
    }
    
    /// Insert new entity
    ///
    /// - Parameters:
    ///   - entity: Entity nme
    ///   - key: key to be set
    ///   - val: val to be set
    /// - Returns: return entity
    public func add(entity : String, key: String, val: Any?)-> NSManagedObject? {
        let entity = NSEntityDescription.insertNewObject(forEntityName: entity, into: managedObjectContext!)
        entity.setValue(val, forKey: key)
        return entity
        
    }
    
    
    
    /// Get entities
    ///
    /// - Parameter entity: entity name
    /// - Returns: Array of NSManagedObject
    public func get(entity : String) ->[NSManagedObject]?  {
        return self.get(entity: entity, predicate: nil, args: nil, relation: nil, sort: nil)
    }
    
    
    //we should not passing query parametr directly like below.
    //"userdata.id == \"\(selectedID!)\""
    //using args is much cleaner
    public func get(entity : String,  predicate : String?, args : [Any]?, sort: [(String,Bool)]?) ->[NSManagedObject]?  {
        return self.get(entity: entity, predicate: predicate, args: args, relation: nil, sort: sort)
    }
    
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
    
    //https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller
    //https://cocoacasts.com/populate-a-table-view-with-nsfetchedresultscontroller-and-swift-3/
    public func fetchRequest(entity : String,  predicate : String?) ->[NSManagedObject]?  {
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "attrkey", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: predicate!)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        
        do {
            try controller.performFetch()
            return controller.fetchedObjects as? [NSManagedObject]
        }
        catch {
            fatalError("There was an error fetching the items")
        }
    }
    
    /// This function is to support to fix missing id. It is historical reason
    /// only and should not be used in reguat code
    ///
    /// - Parameters:
    ///   - entity: NSObject name
    ///   - predicate: NSObject predicate
    /// - Returns: return a list of NSObject
    public func get(entity : String,  predicate : String?) ->[NSManagedObject]?  {
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: predicate!)
        do {
            if let results = try self.managedObjectContext?.fetch(fetchRequest) as? [NSManagedObject] {
                let fetched: [NSManagedObject]? = results
                if fetched != nil {
                    return fetched
                }
            }
        }
        catch {
            fatalError("There was an error fetching the items")
        }
        return nil
    }
}
