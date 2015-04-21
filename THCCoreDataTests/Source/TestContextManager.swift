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

class TestCoreDataConfiguration: XCTestCase {
    func testDefaultConfiguration() {
        let objectModel = NSManagedObjectModel()
        CoreDataConfiguration.defaultManagedObjectModel = objectModel
        CoreDataConfiguration.defaultStoreName = "Test.sqlite"
        let defaultConfig = CoreDataConfiguration.defaultConfiguration
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("THCCoreData").URLByAppendingPathComponent("Test.sqlite")
        
        XCTAssertEqual(storeURL, defaultConfig.storeURL)
        XCTAssertEqual(objectModel, defaultConfig.managedObjectModel)
    }
    
    func testReset() {
        let objectModel = NSManagedObjectModel()
        CoreDataConfiguration.defaultManagedObjectModel = objectModel
        CoreDataConfiguration.defaultStoreName = "Test.sqlite"
        let defaultConfig = CoreDataConfiguration.defaultConfiguration
        // create store
        let manager = ContextManager.defaultManager
        
        let sqliteURL = CoreDataConfiguration.baseFolder.URLByAppendingPathComponent("Test.sqlite")
        
        
        let rawURL = sqliteURL.absoluteString!
        let shmURL = NSURL(string: rawURL.stringByAppendingString("-shm"))!
        let walURL = NSURL(string: rawURL.stringByAppendingString("-wal"))!
        
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(sqliteURL.path!))
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(shmURL.path!))
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(walURL.path!))
        defaultConfig.deleteStore()
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(sqliteURL.path!))
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(shmURL.path!))
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(walURL.path!))
    }
}

class TestContextManager: XCTestCase {

    func testInitializeContextManager() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistentStoreCoordinator: coordinator)
        XCTAssertNotNil(manager.mainContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, manager.mainContext.concurrencyType)
        XCTAssertNotNil(manager.mainContext.parentContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, manager.mainContext.parentContext!.concurrencyType)
    }
    
    func testInitializeWithConfiguration() {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as! NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("CoreData.sqlite")
        let objectModel = NSManagedObjectModel()
        let config = CoreDataConfiguration(storeURL: storeURL, managedObjectModel: objectModel)
        let manager = ContextManager(configuration: config)
        XCTAssertEqual(objectModel, manager.mainContext.persistentStoreCoordinator!.managedObjectModel)
        let persitentStore = manager.mainContext.persistentStoreCoordinator!.persistentStores[0] as! NSPersistentStore
        XCTAssertEqual(storeURL, persitentStore.URL!)
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
