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

import CoreData

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
        context.createObject(StubObject.self)
        context.createObject(StubObject.self)
        context.createObject(StubObject.self)
        XCTAssertEqual(3, requestSet.count)
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
    
    func testFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.filter("name", value:"Test")
        XCTAssertEqual(NSPredicate(format: "name = 'Test'"), requestSet.fetchRequest.predicate!)
    }
    
    func testTupleListFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.filter([(key:"name", value:"Test"), (key:"name", value:"Test2")])
        XCTAssertEqual(NSPredicate(format: "name = 'Test' AND name = 'Test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testORFilter() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        let predicate1 = NSPredicate(format:"name='test1'")
        let predicate2 = NSPredicate(format:"name='test2'")
        requestSet.filter(predicate1).filter(predicate2, mode: RequestFilterMode.OR)
        XCTAssertEqual(NSPredicate(format: "name='test1' OR name='test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testLimit() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        let obj1 = context.createObject(StubObject.self)
        let obj2 = context.createObject(StubObject.self)
        XCTAssertEqual(2, requestSet.count)
        requestSet.limit(1)
        XCTAssertEqual(1, requestSet.count)
    }
    
//    func testOffset() {
//        let context = self.manager!.mainContext
//        let obj1 = context.createObject(StubObject.self)
//        obj1.name = "A"
//        let obj2 = context.createObject(StubObject.self)
//        obj2.name = "B"
//        let obj3 = context.createObject(StubObject.self)
//        obj3.name = "C"
//        
//        // object must be saved to work as expected see TODO in 'RequestSet'
//        let expectation = self.expectationWithDescription("")
//        context.persist({(success, error) in
//            expectation.fulfill()})
//        self.waitForExpectationsWithTimeout(0.01, handler: nil)
//        
//        var requestSet = RequestSet<StubObject>(context:context).sortBy("name").offset(1)
//        
//        // there are even more limitations, the execute count function does not work with the 
//        // fetchOffset values
//        XCTAssertEqual(obj2, requestSet[0])
//        XCTAssertEqual(obj3, requestSet[1])
//        XCTAssertEqual(2, requestSet.count)
//    }
    
    func testSorting() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.sortBy("name")
        XCTAssertEqual(1, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name", requestSet.fetchRequest.sortDescriptors![0].key!!)
        XCTAssertEqual(true, requestSet.fetchRequest.sortDescriptors![0].ascending)
        
        requestSet.sortBy("name2", order: RequestSortOrder.DESCENDING)
        XCTAssertEqual(1, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name2", requestSet.fetchRequest.sortDescriptors![0].key!!)
        XCTAssertEqual(false, requestSet.fetchRequest.sortDescriptors![0].ascending)
    }
    
    func testSortingList() {
        let context = self.manager!.mainContext
        let requestSet = RequestSet<StubObject>(context:context)
        requestSet.sortBy([("name", RequestSortOrder.ASCENDING), ("name2", RequestSortOrder.DESCENDING)])
        XCTAssertEqual(2, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name", requestSet.fetchRequest.sortDescriptors![0].key!!)
        XCTAssertEqual(true, requestSet.fetchRequest.sortDescriptors![0].ascending)
        XCTAssertEqual("name2", requestSet.fetchRequest.sortDescriptors![1].key!!)
        XCTAssertEqual(false, requestSet.fetchRequest.sortDescriptors![1].ascending)
    }
}
