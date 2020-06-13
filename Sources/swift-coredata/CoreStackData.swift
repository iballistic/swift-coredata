//
//  CoreDataStack.swift
//  swift-coredata
//
//  Created by Telman Rustam on 2020-06-13.
//  Copyright © 2020 Telman Rustam. All rights reserved.
//
//https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html
//Core Data Programming Guide
import Foundation
import CoreData

/// <#Description#>
public class CoreStackData{
    
    private var modelName : String
    private var bundleIdentifier : Bundle
    private var storeInFolder : String?
    
    //model name
    public var model : String {
        get{
            return self.modelName
        }
        
    }
    //app bundle name
    public var bundle : Bundle{
        get{
            return self.bundleIdentifier
        }
        
    }
    
    
    /// Description
    /// - Parameters:
    ///   - bundleIdentifierName: app bundle name
    ///   - model: core data model file name (database file name)
    public init(bundleIdentifierName: String, model : String){
        self.modelName = model
        self.bundleIdentifier = Bundle(identifier: bundleIdentifierName)!
    }
    
    
    /// Description
    /// - Parameters:
    ///   - bundleIdentifierName: app bundle name
    ///   - model: core data model file name (database file name)
    ///   - storeInFolder: a sub folder name to store core data model
    public init(bundleIdentifierName: String, model : String, storeInFolder: String?){
        self.modelName = model
        self.storeInFolder = storeInFolder
        self.bundleIdentifier = Bundle(identifier: bundleIdentifierName)!
    }
    
    
    
    // MARK: - Core Data stack
    public lazy var applicationSupportDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        if let path  = self.storeInFolder{
            return appSupportURL.appendingPathComponent(path, isDirectory: true)
        }
        
        return appSupportURL
        
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional.
        // It is a fatal error for the application not to be able to find and load its model.
        // core data is no longer is main bundle use code
        let modelURL = self.bundle.url(forResource: self.model, withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    
    ///The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    ///(The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        if self.applicationSupportDirectory.hasDirectoryPath{
            var isDirectory = ObjCBool(true)
            let dirExist = fileManager.fileExists(atPath: self.applicationSupportDirectory.path, isDirectory: &isDirectory)
            do {
                try fileManager.createDirectory(atPath: self.applicationSupportDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
                failError = error as NSError
            }
            
        }else{
            failureReason = "Expected a folder to store application data, found a file \(self.applicationSupportDirectory.path)."
            shouldFail = true
            
        }
        
        /// Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationSupportDirectory.appendingPathComponent("\(self.model).storedata")
            do {
                let options = [ NSInferMappingModelAutomaticallyOption : true,
                                NSMigratePersistentStoresAutomaticallyOption : true]
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                
                /*
                 Typical reasons for an error here include:
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            if let error = failError {
                //NSApplication.shared().presentError(error)
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
            fatalError("Unsresolved error: \(failureReason)")
        } else {
            return coordinator!
        }
    }()
    
    
    ///Returns the managed object context for the application
    ///(which is already bound to the persistent store coordinator for the application.)
    ///This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}

extension CoreStackData{
    
    //all possible file extensions are listed in here
    public var storeFileExtension : [String]?{
        get{
            return ["storedata","storedata-shm","storedata-wal"]
        }
    }
    
    
    /// Delete coredata files
    public func deleteStoreDataFiles(){
        for ext in self.storeFileExtension!{
            let fileURL = self.applicationSupportDirectory.appendingPathComponent("\(self.model).\(ext)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do{
                    try FileManager.default.removeItem(at: fileURL)
                } catch{
                    print("Error: \(error)")
                }
            }
        }
    }
    
    
}
