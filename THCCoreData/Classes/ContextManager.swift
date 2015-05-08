//
// Created by Christopher weber on 06.04.15.
// Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

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
    
    /**
    Creates a isntance of ContextManager bases on a object model with a sqlite store. The store will be located in documents directory under 'THCCoreData/'
    
    :param: managedObjectModel    the object model which is used to create the database
    :param: recreateStoreIfNeeded If true, the sqlite databse will get recreated if an error occures (default: false)
    
    **Warning:** Only use the 'recreateStoreIfNeeded' for development, this can lead to data loss!
    
    :returns: Instance of ContextManager
    */
    convenience public init?(managedObjectModel: NSManagedObjectModel, recreateStoreIfNeeded: Bool = false) {
        let fileManager = NSFileManager.defaultManager()
        let documentsDir = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        
        let sqliteStoreURL = documentsDir.URLByAppendingPathComponent("THCCoreData/CoreData.sqlite")
        var error: NSError?
        if !fileManager.createDirectoryAtURL(sqliteStoreURL.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil, error:&error) {
            NSException(name: "Exception", reason: "can't create folder in documents", userInfo: nil).raise()
        }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ]
        var store: NSPersistentStore? = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteStoreURL, options: options, error: &error)
        if store == nil {
            if recreateStoreIfNeeded {
                let rawURL = sqliteStoreURL.absoluteString!
                let shmURL = NSURL(string: rawURL.stringByAppendingString("-shm"))!
                let walURL = NSURL(string: rawURL.stringByAppendingString("-wal"))!
                let fileManager = NSFileManager.defaultManager()
                fileManager.removeItemAtURL(sqliteStoreURL, error: nil)
                fileManager.removeItemAtURL(shmURL, error: nil)
                fileManager.removeItemAtURL(walURL, error: nil)
                
                // try initalizing store again
                store = persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteStoreURL, options: options, error: &error)
            }
            if store == nil {
                // TODO: change to optional initializer and remove exception as soon this bug is fixed:
                // http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
                self.init(persistentStoreCoordinator:NSPersistentStoreCoordinator())
                return nil
            }
        }
        self.init(persistentStoreCoordinator:persistentStoreCoordinator)
    }
    
    /**
    Creates a isntance of ContextManager with the merged object models from the main bundle and with a sqlite store. The store will be located in documents directory under 'THCCoreData/'
    
    :param: recreateStoreIfNeeded If true, the sqlite databse will get recreated if an error occures (default: false)
    
    **Warning:** Only use the 'recreateStoreIfNeeded' for development, this can lead to data loss!
    
    :returns: Instance of ContextManager
    */
    convenience public init?(recreateStoreIfNeeded: Bool = false) {
        // TODO: change to optional initializer and remove exception as soon this bug is fixed:
        // http://stackoverflow.com/questions/26495586/best-practice-to-implement-a-failable-initializer-in-swift
        
        var managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        if (managedObjectModel == nil) {
            NSException(name: "Exception", reason: "Could not create managedobject model", userInfo: nil).raise()
        }
        self.init(managedObjectModel: managedObjectModel!, recreateStoreIfNeeded:recreateStoreIfNeeded)
    }
}
