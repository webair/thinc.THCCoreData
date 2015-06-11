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

class TestFetchedTableController: CoreDataTestCase {
    
    func createFetchedTableController(var tableView: UITableView?) -> FetchedTableController {
        let context = self.manager.mainContext
        let requestSet = self.manager.mainContext.requestSet(Stub).sortBy("name")
        if tableView == nil {
            tableView = UITableView()
        }
        let fetchedTableController = FetchedTableController(tableView: tableView!, fetchRequest: requestSet.fetchRequest, context: context)
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
    }
    
    func testBeginUpdates() {
        class MockTableView: UITableView {
            var called = false
            private override func beginUpdates() {
                self.called = true
            }
        }
        
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controllerWillChangeContent(fetchedTableController.fetchedResultsController);
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
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controllerDidChangeContent(fetchedTableController.fetchedResultsController);
        XCTAssertTrue(tableView.called)
    }
    
    func testInsertObject() {
    
        class MockTableView: UITableView {
            var called = false
            private override func insertRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(0, indexPath.row)
                XCTAssertEqual(0, indexPath.section)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeObject: NSObject(), atIndexPath: nil, forChangeType: NSFetchedResultsChangeType.Insert, newIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertTrue(tableView.called)
    }
    
    func testUpdateObject() {
        
        class MockTableView: UITableView {
            var called = false
            private override func reloadRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(0, indexPath.row)
                XCTAssertEqual(0, indexPath.section)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeObject:NSObject() , atIndexPath: NSIndexPath(forRow: 0, inSection: 0), forChangeType: NSFetchedResultsChangeType.Update, newIndexPath:nil)
        XCTAssertTrue(tableView.called)
    }
    
    func testDeleteObject() {
        
        class MockTableView: UITableView {
            var called = false
            private override func deleteRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(0, indexPath.row)
                XCTAssertEqual(0, indexPath.section)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)

            }
        }
        
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeObject:NSObject() , atIndexPath: NSIndexPath(forRow: 0, inSection: 0), forChangeType: NSFetchedResultsChangeType.Delete, newIndexPath:nil)
        XCTAssertTrue(tableView.called)
    }
    
    func testMoveObject() {
        
        class MockTableView: UITableView {
            var calledDelete = false
            var calledInsert = false
            private override func deleteRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.calledDelete = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(0, indexPath.row)
                XCTAssertEqual(0, indexPath.section)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
                
            }
            
            private override func insertRowsAtIndexPaths(indexPaths: [AnyObject], withRowAnimation animation: UITableViewRowAnimation) {
                self.calledInsert = true
                let indexPath = indexPaths[0] as! NSIndexPath
                XCTAssertEqual(1, indexPath.row)
                XCTAssertEqual(0, indexPath.section)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeObject:NSObject() , atIndexPath: NSIndexPath(forRow: 0, inSection: 0), forChangeType: NSFetchedResultsChangeType.Move, newIndexPath:NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertTrue(tableView.calledInsert)
        XCTAssertTrue(tableView.calledDelete)
    }
    
    func testInsertSection() {
        class MockTableView: UITableView {
            var called = false
            private override func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                XCTAssertEqual(0, sections.firstIndex)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        class MockSectionInfo: NSFetchedResultsSectionInfo{
            @objc var name: String? {get{ return nil }}
            @objc var indexTitle: String {get{ return "" }}
            @objc var numberOfObjects: Int {get { return 0 }}
            @objc var objects: [AnyObject] { get {return [NSObject()]} }
        }
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeSection: MockSectionInfo(), atIndex: 0, forChangeType: NSFetchedResultsChangeType.Insert)
        XCTAssertTrue(tableView.called)
    }
    
    func testDeleteSection() {
        class MockTableView: UITableView {
            var called = false
            private override func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
                self.called = true
                XCTAssertEqual(0, sections.firstIndex)
                XCTAssertEqual(UITableViewRowAnimation.Fade, animation)
            }
        }
        class MockSectionInfo: NSFetchedResultsSectionInfo{
            @objc var name: String? {get{ return nil }}
            @objc var indexTitle: String {get{ return "" }}
            @objc var numberOfObjects: Int {get { return 0 }}
            @objc var objects: [AnyObject] { get {return [NSObject()]} }
        }
        let tableView = MockTableView()
        let fetchedTableController = self.createFetchedTableController(tableView)
        fetchedTableController.controller(fetchedTableController.fetchedResultsController, didChangeSection: MockSectionInfo(), atIndex: 0, forChangeType: NSFetchedResultsChangeType.Delete)
        XCTAssertTrue(tableView.called)
    }
}
