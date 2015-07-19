//
//  NSPerstistentStoreExtensionTests.swift
//  THCCoreData
//
//  Created by Chris Weber on 19.07.15.
//  Copyright © 2015 Thinc. All rights reserved.
//

import XCTest
import CoreData
import THCCoreData

class NSPerstistentStoreExtensionTests: XCTestCase {
    
    var storeURL: NSURL!
    
    override func setUp() {
        super.setUp()
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL!
        self.storeURL = documentsDir.URLByAppendingPathComponent("CoreData.sqlite")
        
        let rawURL = storeURL.absoluteString
        let shmURL = NSURL(string: rawURL.stringByAppendingString("-shm"))!
        let walURL = NSURL(string: rawURL.stringByAppendingString("-wal"))!
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(storeURL)
            try fileManager.removeItemAtURL(shmURL)
            try fileManager.removeItemAtURL(walURL)
        } catch _ {
        }
    }
    
    override func tearDown() {
        let documentsDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL!
        self.storeURL = documentsDir.URLByAppendingPathComponent("CoreData.sqlite")
        
        let rawURL = storeURL.absoluteString
        let shmURL = NSURL(string: rawURL.stringByAppendingString("-shm"))!
        let walURL = NSURL(string: rawURL.stringByAppendingString("-wal"))!
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(storeURL)
            try fileManager.removeItemAtURL(shmURL)
            try fileManager.removeItemAtURL(walURL)
        } catch _ {
        }
        super.tearDown()
    }
    
    func testCreateDefaultPersistentStoreCoordinator() {
        let expectedType = NSSQLiteStoreType
        let expectedOptions = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ]
        do {
            let coordinator = try NSPersistentStoreCoordinator.persistentStoreCoordinatorWithDefaultStore(NSManagedObjectModel())
            XCTAssertEqual(1, coordinator.persistentStores.count, "created the store")
            XCTAssertEqual(coordinator.persistentStores[0].URL!, self.storeURL, "store created with correct url")
            XCTAssertEqual(coordinator.persistentStores[0].type, expectedType, "store type is sqlite")
            XCTAssertEqual(coordinator.persistentStores[0].options as! [String:Bool]!, expectedOptions, "store type is sqlite")
        } catch {}
    }
}
