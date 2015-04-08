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
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("THCCoreData").URLByAppendingPathComponent("Test.sqlite")
        
        XCTAssertEqual(storeURL, defaultConfig.storeURL)
        XCTAssertEqual(objectModel, defaultConfig.managedObjectModel)
    }
}

class TestContextManager: XCTestCase {

    func testInitializeContextManager() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistanceStoreCoordinator: coordinator)
        XCTAssertNotNil(manager.mainContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, manager.mainContext.concurrencyType)
        XCTAssertNotNil(manager.mainContext.parentContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, manager.mainContext.parentContext!.concurrencyType)
    }
    
    func testInitializeWithConfiguration() {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL
        let storeURL = documentsDir.URLByAppendingPathComponent("CoreData.sqlite")
        let objectModel = NSManagedObjectModel()
        let config = CoreDataConfiguration(storeURL: storeURL, managedObjectModel: objectModel)
        let manager = ContextManager(configuration: config)
        XCTAssertEqual(objectModel, manager.mainContext.persistentStoreCoordinator!.managedObjectModel)
        let persitentStore = manager.mainContext.persistentStoreCoordinator!.persistentStores[0] as NSPersistentStore
        XCTAssertEqual(storeURL, persitentStore.URL!)
    }
    
    func testPrivateContext() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistanceStoreCoordinator: coordinator)
        let privateContext = manager.privateContext
        XCTAssertEqual(manager.mainContext, privateContext.parentContext!)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, privateContext.concurrencyType)
    }
}
