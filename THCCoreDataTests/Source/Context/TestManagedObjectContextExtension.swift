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
import THCCoreData

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
    
    func testRequestSet() {
        let context = self.manager!.mainContext
        let requestSet = context.requestSet(StubObject.self)
        XCTAssertNotNil(requestSet)
    }
    
    func testPersist() {
        let context = self.manager!.mainContext
        let obj = context.createObject(StubObject)
        obj.name = "test"
        let expectation = self.expectationWithDescription("Called success")
        context.persist({(success:Bool, error:NSError?) -> Void in
            XCTAssertTrue(success)
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(0.1, handler: nil)
        XCTAssertEqual(1, self.manager!.mainContext.parentContext!.countForFetchRequest(context.fetchRequest(StubObject), error: nil))
    }
}
