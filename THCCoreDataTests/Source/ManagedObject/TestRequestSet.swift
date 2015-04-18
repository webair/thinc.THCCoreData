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

    func testPredicateFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        let predicate = NSPredicate(format:"name='test'")
        requestSet.filter(predicate)
        XCTAssertEqual(predicate, requestSet.fetchRequest.predicate!)
    }
    
    func testChainFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        let predicate1 = NSPredicate(format:"name='test1'")
        let predicate2 = NSPredicate(format:"name='test2'")
        requestSet.filter(predicate1).filter(predicate2)
        XCTAssertEqual(NSPredicate(format: "name='test1' AND name='test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testTupleFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.filter((key:"name", value:"Test"))
        XCTAssertEqual(NSPredicate(format: "name='Test'"), requestSet.fetchRequest.predicate!)
    }
    
    func testTupleListFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.filter([(key:"name", value:"Test"), (key:"name", value:"Test2")])
        XCTAssertEqual(NSPredicate(format: "name='Test' AND name='Test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testORFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        let predicate1 = NSPredicate(format:"name='test1'")
        let predicate2 = NSPredicate(format:"name='test2'")
        requestSet.filter(predicate1).filter(predicate2, mode: FilterMode.OR)
        XCTAssertEqual(NSPredicate(format: "name='test1' OR name='test2'"), requestSet.fetchRequest.predicate!)
    }
}
