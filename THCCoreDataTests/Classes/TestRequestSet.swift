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
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        XCTAssertEqual(context, requestSet.context)
    }
    
    func testCount() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        XCTAssertEqual(0, requestSet.count)
        context.createObject(Stub.self)
        context.createObject(Stub.self)
        context.createObject(Stub.self)
        XCTAssertEqual(3, requestSet.count)
    }
    
    func testSubscript() {
        let context = self.manager.mainContext
        let object = context.createObject(Stub.self)
        let requestSet = RequestSet<Stub>(context:context)
        XCTAssertEqual(object, requestSet[0])
    }
    
    func testIterate() {
        let context = self.manager.mainContext
        context.createObject(Stub.self)
        let requestSet = RequestSet<Stub>(context:context)
        for fetchedObject in requestSet {
            print(fetchedObject)
        }
    }

    func testPredicateFilter() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        let predicate = NSPredicate(format:"name='test'")
        requestSet.filter(predicate)
        XCTAssertEqual(predicate, requestSet.fetchRequest.predicate!)
    }
    
    func testChainFilter() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        let predicate1 = NSPredicate(format:"name='test1'")
        let predicate2 = NSPredicate(format:"name='test2'")
        requestSet.filter(predicate1).filter(predicate2)
        XCTAssertEqual(NSPredicate(format: "name='test1' AND name='test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testFilter() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        requestSet.filter("name", value:"Test")
        XCTAssertEqual(NSPredicate(format: "name = 'Test'"), requestSet.fetchRequest.predicate!)
    }
    
    func testTupleListFilter() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        requestSet.filter([(key:"name", value:"Test"), (key:"name", value:"Test2")])
        XCTAssertEqual(NSPredicate(format: "name = 'Test' AND name = 'Test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testORFilter() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        let predicate1 = NSPredicate(format:"name='test1'")
        let predicate2 = NSPredicate(format:"name='test2'")
        requestSet.filter(predicate1).filter(predicate2, mode: RequestFilterMode.OR)
        XCTAssertEqual(NSPredicate(format: "name='test1' OR name='test2'"), requestSet.fetchRequest.predicate!)
    }
    
    func testLimit() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        context.createObject(Stub.self)
        context.createObject(Stub.self)
        XCTAssertEqual(2, requestSet.count)
        requestSet.limit(1)
        XCTAssertEqual(1, requestSet.count)
    }
    
    func testSorting() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        requestSet.sortBy("name")
        XCTAssertEqual(1, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name", requestSet.fetchRequest.sortDescriptors![0].key!)
        XCTAssertEqual(true, requestSet.fetchRequest.sortDescriptors![0].ascending)
        
        requestSet.sortBy("name2", order: RequestSortOrder.DESCENDING)
        XCTAssertEqual(1, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name2", requestSet.fetchRequest.sortDescriptors![0].key!)
        XCTAssertEqual(false, requestSet.fetchRequest.sortDescriptors![0].ascending)
    }
    
    func testSortingList() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        requestSet.sortBy([("name", RequestSortOrder.ASCENDING), ("name2", RequestSortOrder.DESCENDING)])
        XCTAssertEqual(2, requestSet.fetchRequest.sortDescriptors!.count)
        XCTAssertEqual("name", requestSet.fetchRequest.sortDescriptors![0].key!)
        XCTAssertEqual(true, requestSet.fetchRequest.sortDescriptors![0].ascending)
        XCTAssertEqual("name2", requestSet.fetchRequest.sortDescriptors![1].key!)
        XCTAssertEqual(false, requestSet.fetchRequest.sortDescriptors![1].ascending)
    }
    
    func testResetFetchRequest() {
        let context = self.manager.mainContext
        let requestSet = RequestSet<Stub>(context:context)
        requestSet.filter("name", value: "A")
        requestSet.sortBy("name")
        requestSet.limit(1)
        requestSet.reset()
        let fetchRequest = requestSet.fetchRequest
        XCTAssertNil(fetchRequest.predicate)
        XCTAssertNil(fetchRequest.sortDescriptors)
        XCTAssertEqual(fetchRequest.fetchLimit, 0)
    }
    
//    func testFlush() {
//        let context = self.manager.mainContext
//        let requestSet = RequestSet<Stub>(context:context)
//        XCTAssertEqual(0, requestSet.count)
//        let obj1 = context.createObject(Stub.self)
//        // will still be 0
//        XCTAssertEqual(0, requestSet.count)
//        requestSet.flush()
//        // count will be 1 now
//        XCTAssertEqual(1, requestSet.count)
//    }
}
