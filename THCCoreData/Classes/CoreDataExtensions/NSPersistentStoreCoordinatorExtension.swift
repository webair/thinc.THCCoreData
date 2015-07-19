//
//  File.swift
//  THCCoreData
//
//  Created by Chris Weber on 19.07.15.
//  Copyright © 2015 Thinc. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
    
    public static func persistentStoreCoordinatorWithDefaultStore(managedObjectModel:NSManagedObjectModel, recreateStoreIfNeeded:Bool=false) throws -> NSPersistentStoreCoordinator {
        
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL!
        let sqliteStoreURL = documentsDir.URLByAppendingPathComponent("CoreData.sqlite")
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ]
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: sqliteStoreURL, options: options)

        return coordinator
    }
}