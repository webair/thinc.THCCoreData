//
//  TestContextManager.swift
//  THCCoreData
//
//  Created by Christopher weber on 06.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import THCCoreData
import CoreData

class TestContextManager: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // clean up default store directory
        let storeDirectoryURL = self.defaultStoreURL().URLByDeletingLastPathComponent!
        if NSFileManager.defaultManager().fileExistsAtPath(storeDirectoryURL.path!) {
            if (NSFileManager.defaultManager().removeItemAtURL(storeDirectoryURL, error: nil)) {
                println("successfully deleted default store directory")
            } else {
                println("error while deleted default store directory")
            }
        }
    }
    
    func defaultStoreURL() -> NSURL {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        return documentsDir.URLByAppendingPathComponent("THCCoreData/CoreData.sqlite")
    }

    func testInitializeContextManager() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistentStoreCoordinator: coordinator)
        XCTAssertNotNil(manager.mainContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, manager.mainContext.concurrencyType)
        XCTAssertNotNil(manager.mainContext.parentContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, manager.mainContext.parentContext!.concurrencyType)
    }
    
    func testInitializeDefaultStore() {
        let objectModel = NSManagedObjectModel()
        let storeURL = self.defaultStoreURL()
        
        var manager = ContextManager(managedObjectModel: objectModel)
        var store = manager!.mainContext.persistentStoreCoordinator!.persistentStoreForURL(storeURL)
        
        XCTAssertNotNil(store)
        XCTAssertEqual(objectModel, manager!.mainContext.persistentStoreCoordinator!.managedObjectModel)
        
        // check if sqlite file got created
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(storeURL.path!))
    }
    
    func testCreateStoreFailed() {
        let objectModel = NSManagedObjectModel()
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("THCCoreData/CoreData.sqlite")
        var manager = ContextManager(managedObjectModel: objectModel)
        XCTAssertNotNil(manager)
        
        // fake scheme change
        var objectModel2 = NSManagedObjectModel()
        let newEntity = NSEntityDescription()
        newEntity.name = "NewEntity"
        objectModel2.entities = [newEntity]
        manager = ContextManager(managedObjectModel: objectModel2)
        XCTAssertNil(manager)
    }
    
    func testRecreatingDefaultStore() {
        let objectModel = NSManagedObjectModel()
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("THCCoreData/CoreData.sqlite")
        var manager = ContextManager(managedObjectModel: objectModel)
        XCTAssertNotNil(manager)
        
        // fake scheme change
        var objectModel2 = NSManagedObjectModel()
        let newEntity = NSEntityDescription()
        newEntity.name = "NewEntity"
        objectModel2.entities = [newEntity]
        manager = ContextManager(managedObjectModel: objectModel2, recreateStoreIfNeeded: true)
        XCTAssertNotNil(manager)
    }
    
    func testPrivateContext() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistentStoreCoordinator: coordinator)
        let privateContext = manager.privateContext
        XCTAssertEqual(manager.mainContext, privateContext.parentContext!)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, privateContext.concurrencyType)
    }
}
