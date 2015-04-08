//
// Created by Christopher weber on 06.04.15.
// Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public struct CoreDataConfiguration {
    
    public static var defaultStoreName = "CoreData.sqlite"
    public static var defaultManagedObjectModel: NSManagedObjectModel?
    
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
    
    public init (storeURL: NSURL, managedObjectModel: NSManagedObjectModel) {
        self.storeURL = storeURL
        self.managedObjectModel = managedObjectModel
    }
    
    public var storeURL: NSURL
    public var managedObjectModel: NSManagedObjectModel
    
}

public class ContextManager {
    
    
    private let writerContext: NSManagedObjectContext
    
    /// The Main managed object context
    public let mainContext: NSManagedObjectContext
    
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
