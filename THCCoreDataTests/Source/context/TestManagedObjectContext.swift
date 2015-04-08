//
//  TestManagedObjectContext.swift
//  THCCoreData
//
//  Created by Christopher weber on 06.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import THCCoreData
import CoreData

class TestManagedObjectContext: XCTestCase {
    
    var manager: ContextManager?
    
    override func setUp() {
        let objectModelURL = NSBundle(forClass: TestManagedObjectContext.self).URLForResource("Model", withExtension: "momd")!
        let objectModel = NSManagedObjectModel(contentsOfURL: objectModelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        self.manager = ContextManager(persistanceStoreCoordinator: coordinator)
    }
    
    func testCreateObject() {
        let context = self.manager!.mainContext
        let stub: StubObject = context.createObject(StubObject.self)
        XCTAssertNotNil(stub)
    }
}
