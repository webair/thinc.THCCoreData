//
//  TestManagedObjectExtension.swift
//  THCCoreData
//
//  Created by Christopher weber on 09.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import XCTest

class TestManagedObjectExtension: CoreDataTestCase {

    func testEntityName() {
        // automatic detection
        XCTAssertEqual("Stub", Stub.entityName())
        //overidden
        XCTAssertEqual("StubEntity", StubObject.entityName())
    }
    
    func testCreate() {
        let object:Any = StubObject.create(self.manager.mainContext)
        XCTAssertTrue(object is StubObject)
    }
}