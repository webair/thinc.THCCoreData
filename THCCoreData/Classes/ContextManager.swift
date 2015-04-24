//
// Created by Christopher weber on 06.04.15.
// Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

/**
*  Used to configurate the CoreData environment
*/
public struct CoreDataConfiguration {
    
    /// Base Folder, where the stores and configuration will be saved
    public static let baseFolder: NSURL = {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        return documentsDir.URLByAppendingPathComponent("THCCoreData")
    }()
    
    /// Name of the sqlite store which will be used for the default configuration (defaul: CoreData.sqlite)
    public static var defaultStoreName = "CoreData.sqlite"
    
    /// The managed object model which should be used for the default configuration (default: nil, will merge all model file from main bundle)
    public static var defaultManagedObjectModel: NSManagedObjectModel?
    
    /// The default configuration
    public static var defaultConfiguration: CoreDataConfiguration {get{
        var error: NSError?
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.createDirectoryAtURL(CoreDataConfiguration.baseFolder, withIntermediateDirectories: true, attributes: nil, error:&error) {
            NSException(name: "Exception", reason: "can't create folder in documents", userInfo: nil).raise()
        }
        
        var managedObjectModel: NSManagedObjectModel?
        if CoreDataConfiguration.defaultManagedObjectModel != nil {
            managedObjectModel = defaultManagedObjectModel
        } else {
            managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!;
        }
        return CoreDataConfiguration(storeURL: CoreDataConfiguration.baseFolder.URLByAppendingPathComponent(defaultStoreName), managedObjectModel:managedObjectModel!)
        }
    }
    
    /**
    Creates a instance
    
    :param: storeURL           URL of the store
    :param: managedObjectModel A NSManagedOBjectModel instance
    
    :returns: Instance of CoreDataConfiguration
    */
    public init (storeURL: NSURL, managedObjectModel: NSManagedObjectModel) {
        self.storeURL = storeURL
        self.managedObjectModel = managedObjectModel
    }
    
    /// URL of the sqlite store
    private(set) public var storeURL: NSURL
    
    /// The NSManagedObject model
    public var managedObjectModel: NSManagedObjectModel
    
    /**
    Deletes the underlaying store
    */
    public func deleteStore() {
        let fileManager = NSFileManager.defaultManager()
        
        let rawURL = self.storeURL.absoluteString!
        let shmURL = NSURL(string: rawURL.stringByAppendingString("-shm"))!
        let walURL = NSURL(string: rawURL.stringByAppendingString("-wal"))!

        fileManager.removeItemAtURL(self.storeURL, error: nil)
        fileManager.removeItemAtURL(shmURL, error: nil)
        fileManager.removeItemAtURL(walURL, error: nil)
    }
    
}

/**
*  Manages the NSManagedObjectContext instances. It sets up an efficient Core Data stack with support for creating multiple child managed object contexts. It has a built-in private managed object context that does asynchronous saving to an SQLite Store
*/
public class ContextManager {
    
    private let writerContext: NSManagedObjectContext
    
    /// The Main managed object context
    public let mainContext: NSManagedObjectContext
    
    /// A new private Context, which has the main NSManagedContext as parent
    public var privateContext: NSManagedObjectContext {get {
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.parentContext = self.mainContext
        return privateContext
        }
    }
    
    /// The default ContextManager created by the default CoreDataConfiguration instance @see CoreDataConfiguration
    public static let defaultManager: ContextManager = {
        return ContextManager(configuration: CoreDataConfiguration.defaultConfiguration)
    }()
    
    /**
    Creates a instance
    
    :param: Core Data configuration for the manager
    
    :returns: Instance of ContextManager
    */
    public convenience init(configuration: CoreDataConfiguration) {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: configuration.managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption : true,NSInferMappingModelAutomaticallyOption : true]
        var error: NSError?
        var store: NSPersistentStore? = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: configuration.storeURL, options: options, error: &error)
        if store == nil {
            println("Could not create store: \(error)")
        }
        self.init(persistentStoreCoordinator: persistentStoreCoordinator)
    }

    /**
    Creates a instance of ContextManager
    
    :param: persistentStoreCoordinator NSPersistentStoreCoordinator which will be used by the manager to create the NSMAnagedObjectContext instances
    
    :returns: Instance of ContextManager
    */
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.writerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.writerContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.mainContext.parentContext = self.writerContext
    }
}
