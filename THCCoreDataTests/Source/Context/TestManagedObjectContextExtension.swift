//
//  TestManagedObjectContext.swift
//  THCCoreData
//
//  Created by Christopher weber on 06.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class TestManagedObjectContextExtension: CoreDataTestCase {
    
    func testFetchRequest() {
        let context = self.manager!.mainContext
        let fetchRequest = context.fetchRequest(StubObject.self)
        XCTAssertEqual(StubObject.entityName(), fetchRequest.entityName!)
    }
    
    func testCreateObject() {
        let context = self.manager!.mainContext
        let stub: StubObject = context.createObject(StubObject.self)
        XCTAssertNotNil(stub)
    }
}
