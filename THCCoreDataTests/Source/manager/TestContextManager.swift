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

    func testInitializeContextManager() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistanceStoreCoordinator: coordinator)
        XCTAssertNotNil(manager.mainContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, manager.mainContext.concurrencyType)
        XCTAssertNotNil(manager.mainContext.parentContext)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, manager.mainContext.parentContext!.concurrencyType)
    }
    
    func testPrivateContext() {
        let objectModel = NSManagedObjectModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let manager = ContextManager(persistanceStoreCoordinator: coordinator)
        let privateContext = manager.privateContext()
        XCTAssertEqual(manager.mainContext, privateContext.parentContext!)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType, privateContext.concurrencyType)
    }

}
