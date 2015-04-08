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
    
    /// Name of the sqlite store which will be used for the default configuration (defaul: CoreData.sqlite)
    public static var defaultStoreName = "CoreData.sqlite"
    
    /// The managed object model which should be used for the default configuration (default: nil, will merge all model file from main bundle)
    public static var defaultManagedObjectModel: NSManagedObjectModel?
    
    /// The default configuration
    public static var defaultConfiguration: CoreDataConfiguration {get{
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        let rootFolder = documentsDir.URLByAppendingPathComponent("THCCoreData")
        var error: NSError?
        NSFileManager.defaultManager().createDirectoryAtURL(rootFolder, withIntermediateDirectories: true, attributes: nil, error: &error)
        if error != nil {
            NSException(name: "Exception", reason: "can't create folder in documents", userInfo: nil).raise()
        }
        var managedObjectModel: NSManagedObjectModel?
        if CoreDataConfiguration.defaultManagedObjectModel != nil {
            managedObjectModel = defaultManagedObjectModel
        } else {
            managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!;
        }
        return CoreDataConfiguration(storeURL: rootFolder.URLByAppendingPathComponent(defaultStoreName), managedObjectModel:managedObjectModel!)
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
    public var storeURL: NSURL
    
    /// The NS;anagedObject model
    public var managedObjectModel: NSManagedObjectModel
    
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
    public class var defaultManager: ContextManager {
        struct Static {
            static var instance: ContextManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            
            Static.instance = ContextManager(configuration: CoreDataConfiguration.defaultConfiguration)
        }
        return Static.instance!
    }
    
    /**
    Creates a instance
    
    :param: Core Data configuration for the manager
    
    :returns: Instance of ContextManager
    */
    public convenience init(configuration: CoreDataConfiguration) {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: configuration.managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption : true,NSInferMappingModelAutomaticallyOption : true]
        var error: NSError?
        persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: configuration.storeURL, options: options, error: &error)
        if error != nil {
            NSException(name: "Exception", reason: "can't create sqliteStore at URL \(configuration.storeURL)", userInfo: nil).raise()
        }
        self.init(persistanceStoreCoordinator: persistentStoreCoordinator)
    }

    /**
    Creates a instance of ContextManager
    
    :param: persistanceStoreCoordinator NSPersistentStoreCoordinator which will be used by the manager to create the NSMAnagedObjectContext instances
    
    :returns: Instance of ContextManager
    */
    public init(persistanceStoreCoordinator: NSPersistentStoreCoordinator) {
        self.writerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.writerContext.persistentStoreCoordinator = persistanceStoreCoordinator
        self.mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.mainContext.parentContext = self.writerContext
    }
}
