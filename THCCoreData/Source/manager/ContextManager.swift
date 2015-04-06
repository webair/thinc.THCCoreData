//
// Created by Christopher weber on 06.04.15.
// Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public class ContextManager {
    
    
    private let writerContext: NSManagedObjectContext
    
    /// The Main managed object context
    public let mainContext: NSManagedObjectContext
    
    class var defaultSqliteURL: NSURL! {
        get{
            let fileManager = NSFileManager.defaultManager()
            let coreDataDirectory = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask).last!.URLByAppendingPathComponent("THCCoreData")
            var error: NSError?
            fileManager.createDirectoryAtURL(coreDataDirectory, withIntermediateDirectories: true, attributes: nil, error: &error)
            if error != nil {
                NSException.raise("Exception", format:"Can't create CoreData folder: %@", arguments:getVaList([error!]))
            }
            return coreDataDirectory.URLByAppendingPathComponent("CoreData.sqlite")
        }
    }
    
    /// The default manager, will create a SQLite persistent store database and is based on the object model from the main bundle. The sqlite database will be placed in the folder 'THCCoreData' in the documents directory
    public class var defaultManager: ContextManager {
        struct Static {
            static var instance: ContextManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            var objectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
            if objectModel == nil {
                NSException(name: "Exception", reason: "Could not create object model, maby object file in bundle is missing", userInfo: nil).raise()
            }
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel!)
            
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : true]
            
            var error: NSError?
            coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: ContextManager.defaultSqliteURL, options: options, error: nil)
            if error != nil {
                NSException.raise("Exception", format:"Can't add default store to coordinator: %@", arguments:getVaList([error!]))
            }
            
            
            Static.instance = ContextManager(persistanceStoreCoordinator: coordinator)
        }
        return Static.instance!
    }

    public init(persistanceStoreCoordinator: NSPersistentStoreCoordinator) {
        self.writerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.writerContext.persistentStoreCoordinator = persistanceStoreCoordinator
        self.mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.mainContext.parentContext = self.writerContext
    }
    
    public func privateContext() -> NSManagedObjectContext {
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.parentContext = self.mainContext
        return privateContext
    }
}
