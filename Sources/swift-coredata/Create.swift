//
//  File.swift
//  
//
//  Created by Telman Rustam on 2021-02-25.
//

import Foundation
import CoreData

extension CRUD{

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
    
}
