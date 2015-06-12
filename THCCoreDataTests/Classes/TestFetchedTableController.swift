//
//  TestFetchedTableController.swift
//  THCCoreData
//
//  Created by Christopher weber on 05.06.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import THCCoreData
import CoreData

class BaseMockFetchedResultsDelegate: FetchedResultsDelegate {
    func beginUpdate() {}
    func endUpdate() {}
    func insertSection(sectionIndex: Int) {}
    func deleteSection(sectionIndex: Int) {}
    func insertObject(indexPath:NSIndexPath){}
    func updateObject(indexPath:NSIndexPath){}
    func deleteObject(indexPath:NSIndexPath){}
    func moveObject(indexPath: NSIndexPath, newIndexPath: NSIndexPath) {}
}

class TestFetchedResultsControllerDelegateAdapter: XCTestCase {
    func testBeginUpdates() {
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func beginUpdate() {
                self.called = true
            }
        }
    
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controllerWillChangeContent(NSFetchedResultsController());
        XCTAssertTrue(mock.called)
    }
    
    func testEndUpdates() {
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func endUpdate() {
                self.called = true
            }
        }
        
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controllerDidChangeContent(NSFetchedResultsController());
        XCTAssertTrue(mock.called)
    }
    
    func testInsertObject() {
        
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func insertObject(indexPath: NSIndexPath) {
                self.called = true
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
            }
        }
        
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeObject: NSObject(), atIndexPath: nil, forChangeType: NSFetchedResultsChangeType.Insert, newIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertTrue(mock.called)
    }
    
    func testUpdateObject() {
        
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func updateObject(indexPath: NSIndexPath) {
                self.called = true
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
            }
        }
        
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeObject: NSObject(), atIndexPath: NSIndexPath(forRow: 1, inSection: 0), forChangeType: NSFetchedResultsChangeType.Update, newIndexPath: nil)
        XCTAssertTrue(mock.called)
    }
    
    func testDeleteObject() {
        
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func deleteObject(indexPath: NSIndexPath) {
                self.called = true
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
            }
        }
        
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeObject: NSObject(), atIndexPath: NSIndexPath(forRow: 1, inSection: 0), forChangeType: NSFetchedResultsChangeType.Delete, newIndexPath: nil)
        XCTAssertTrue(mock.called)
    }
    
    func testMoveObject() {
        
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func moveObject(indexPath: NSIndexPath, newIndexPath: NSIndexPath) {
                self.called = true
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
                XCTAssertEqual(NSIndexPath(forRow: 2, inSection: 0), newIndexPath)
            }
        }
        
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeObject: NSObject(), atIndexPath: NSIndexPath(forRow: 1, inSection: 0), forChangeType: NSFetchedResultsChangeType.Move, newIndexPath: NSIndexPath(forRow: 2, inSection: 0))
        XCTAssertTrue(mock.called)
    }
    
    func testInsertSection() {
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func insertSection(sectionIndex:Int) {
                self.called = true
                XCTAssertEqual(1, sectionIndex)
            }
        }
        class StubSectionInfo: NSFetchedResultsSectionInfo{
            @objc var name: String? {get{ return nil }}
            @objc var indexTitle: String {get{ return "" }}
            @objc var numberOfObjects: Int {get { return 0 }}
            @objc var objects: [AnyObject] { get {return [NSObject()]} }
        }
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeSection: StubSectionInfo(), atIndex: 1, forChangeType: NSFetchedResultsChangeType.Insert)
        XCTAssertTrue(mock.called)
    }
    
    func testDeleteSection() {
        class MockFetchedResultsDelegate: BaseMockFetchedResultsDelegate {
            var called = false
            override func deleteSection(sectionIndex:Int) {
                self.called = true
                XCTAssertEqual(1, sectionIndex)
            }
        }
        class StubSectionInfo: NSFetchedResultsSectionInfo{
            @objc var name: String? {get{ return nil }}
            @objc var indexTitle: String {get{ return "" }}
            @objc var numberOfObjects: Int {get { return 0 }}
            @objc var objects: [AnyObject] { get {return [NSObject()]} }
        }
        let mock = MockFetchedResultsDelegate()
        let adapter = FetchedResultsControllerDelegateAdapter(delegate:mock)
        adapter.controller(NSFetchedResultsController(), didChangeSection: StubSectionInfo(), atIndex: 1, forChangeType: NSFetchedResultsChangeType.Delete)
        XCTAssertTrue(mock.called)
    }
    
    
    
}

class TestFetchedTableController: CoreDataTestCase {
    
    func createFetchedTableController(var tableView: UITableView?) -> FetchedTableController<Stub> {
        let context = self.manager.mainContext
        let requestSet = self.manager.mainContext.requestSet(Stub).sortBy("name")
        if tableView == nil {
            tableView = UITableView()
        }
        let fetchedTableController = FetchedTableController<Stub>(tableView: tableView!, fetchRequest: requestSet.fetchRequest, context: context)
        return fetchedTableController
    }
    
    func testFetch() {
        Stub.create(self.manager.mainContext)
        self.manager.mainContext.save(nil)
        let fetchedTableController = self.createFetchedTableController(nil)
        let result = fetchedTableController.fetch()
        XCTAssertNil(result.error)
        XCTAssertTrue(result.success)
        XCTAssertEqual(1, fetchedTableController.numberOfSections())
        XCTAssertEqual(1, fetchedTableController.numberOfRowsInSection(0))
        
        Stub.create(self.manager.mainContext)
        self.manager.mainContext.save(nil)
        
        XCTAssertEqual(1, fetchedTableController.numberOfSections())
        XCTAssertEqual(2, fetchedTableController.numberOfRowsInSection(0))
    }

    func testBeginUpdates() {
        class MockTableView: UITableView {
            var called = false
            private override func beginUpdates() {
                self.called = true
            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).beginUpdate()
        XCTAssertTrue(tableView.called)
    }

    func testEndUpdates() {
        class MockTableView: UITableView {
            var called = false
            private override func endUpdates() {
                self.called = true
            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).endUpdate()
        XCTAssertTrue(tableView.called)
    }

    func testInsertObject() {
    
        class MockTableView: UITableView {
            var called = false
            private override func insertRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).insertObject(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertTrue(tableView.called)
    }

    func testUpdateObject() {
        
        class MockTableView: UITableView {
            var called = false
            private override func reloadRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).updateObject(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertTrue(tableView.called)
    }

    func testDeleteObject() {
        
        class MockTableView: UITableView {
            var called = false
            private override func deleteRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)

            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).deleteObject(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertTrue(tableView.called)
    }

    func testMoveObject() {
        
        class MockTableView: UITableView {
            var calledDelete = false
            var calledInsert = false
            private override func deleteRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.calledDelete = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(NSIndexPath(forRow: 1, inSection: 0), indexPath)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
                
            }
            
            private override func insertRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.calledInsert = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(NSIndexPath(forRow: 2, inSection: 0), indexPath)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).moveObject(NSIndexPath(forRow: 1, inSection: 0), newIndexPath: NSIndexPath(forRow: 2, inSection: 0))
        XCTAssertTrue(tableView.calledInsert)
        XCTAssertTrue(tableView.calledDelete)
    }

    func testInsertSection() {
        class MockTableView: UITableView {
            var called = false
            private override func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                XCTAssertEqual(1, sections.firstIndex)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).insertSection(1)
        XCTAssertTrue(tableView.called)
    }

    func testDeleteSection() {
        class MockTableView: UITableView {
            var called = false
            private override func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                XCTAssertEqual(1, sections.firstIndex)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        let tableView = MockTableView()
        self.createFetchedTableController(tableView).deleteSection(1)
        XCTAssertTrue(tableView.called)
    }
}
