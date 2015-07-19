//
// Created by Christopher weber on 06.04.15.
// Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

/**
Manages the NSManagedObjectContext instances. It sets up an efficient Core Data stack with support 
for creating multiple child managed object contexts. It has a built-in private managed object 
context that does asynchronous saving to an SQLite Store
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
    
    - parameter persistentStoreCoordinator: NSPersistentStoreCoordinator which will be used by the manager to create the NSMAnagedObjectContext instances
    
    - returns: Instance of ContextManager
    */
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.writerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        self.writerContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        self.mainContext.parentContext = self.writerContext
    }
}
