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
}
