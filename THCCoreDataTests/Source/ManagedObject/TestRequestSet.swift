//
//  TestRequestSet.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import THCCoreData

class TestRequestSet: CoreDataTestCase {
    func testInit () {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        XCTAssertEqual(context, requestSet.context)
    }
    
    func testCount() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        XCTAssertEqual(0, requestSet.count)
        let object = context.createObject(StubObject.self)
        XCTAssertEqual(1, requestSet.count)
    }
    
    func testSubscript() {
        let context = self.manager!.mainContext
        let object = context.createObject(StubObject.self)
        let requestSet = RequestSet<StubObject>(context:context)
        XCTAssertEqual(object, requestSet[0])
    }
    
    func testIterate() {
        let context = self.manager!.mainContext
        let object = context.createObject(StubObject.self)
        let requestSet = RequestSet<StubObject>(context:context)
        for fetchedObject in requestSet {
            println(fetchedObject)
        }
    }
}
