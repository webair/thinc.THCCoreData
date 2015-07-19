//
//  File.swift
//  THCCoreData
//
//  Created by Christopher weber on 08.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import CoreData

public protocol FetchedResultsDelegate: class {
    func beginUpdate()
    func endUpdate()
    
    func updateObject(indexPath:NSIndexPath)
    func insertObject(indexPath:NSIndexPath)
    func deleteObject(indexPath:NSIndexPath)
    func moveObject(indexPath:NSIndexPath, newIndexPath:NSIndexPath)
    
    func insertSection(sectionIndex:Int)
    func deleteSection(sectionIndex:Int)
}

public class FetchedTableController<T:NSManagedObject>: FetchedResultsDelegate {

    /// table view which will get updated
    public let tableView: UITableView
    
    /// internal fetchedResultsController which is used for updating the table view
    public var fetchedResultsController: NSFetchedResultsController
    
    /// adapter class for delegate calles
    private var resultsControllerDelegate: FetchedResultsControllerDelegateAdapter?
    
    /**
    Initializes a FetchedTableController
    
    - parameter tableView:      corresponding table view
    - parameter fetchRequest:   used fetch request
    - parameter context:        used context
    - parameter sectionKeyPath: section key path for section support
    
    - returns: initialized fetched table controller
    */
    public init(tableView: UITableView, fetchRequest: NSFetchRequest, context:NSManagedObjectContext, sectionKeyPath:String?=nil) {
        self.tableView = tableView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        self.resultsControllerDelegate = FetchedResultsControllerDelegateAdapter(delegate: self)
        self.fetchedResultsController.delegate = self.resultsControllerDelegate
    }
    
    /**
    Fetched the giben fetch request
    
    - returns: tuple if fetches succeeded
    */
    public func fetch() -> (success:Bool, error: NSError?) {
        var error: NSError?
        let success: Bool
        do {
            try self.fetchedResultsController.performFetch()
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        return (success, error)
    }
    
    public func beginUpdate() {
        self.tableView.beginUpdates()
    }
    
    public func endUpdate() {
        self.tableView.endUpdates()
    }
    
    public func insertObject(indexPath: NSIndexPath) {
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    public func updateObject(indexPath: NSIndexPath) {
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    public func deleteObject(indexPath: NSIndexPath) {
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    public func moveObject(indexPath: NSIndexPath, newIndexPath: NSIndexPath) {
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    public func insertSection(sectionIndex: Int) {
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    public func deleteSection(sectionIndex: Int) {
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    /**
    Number of section for the current fetch request
    
    - returns: number of section
    */
    public func numberOfSections() -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    /**
    
    - parameter sectionIndex: given section index
    
    - returns: number of objects for the given section index
    */
    public func numberOfRowsInSection(sectionIndex: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![sectionIndex] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
}

/**
*  Class for handling the delegate, because generics don't work for this
*/
public class FetchedResultsControllerDelegateAdapter: NSObject, NSFetchedResultsControllerDelegate {
    
    private let fetchedResultsDelegate: FetchedResultsDelegate
    
    public init (delegate: FetchedResultsDelegate) {
        self.fetchedResultsDelegate = delegate
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.fetchedResultsDelegate.beginUpdate()
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.fetchedResultsDelegate.endUpdate()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
        case .Insert:
            self.fetchedResultsDelegate.insertObject(newIndexPath!)
        case .Update:
            self.fetchedResultsDelegate.updateObject(indexPath!)
        case .Move:
            self.fetchedResultsDelegate.moveObject(indexPath!, newIndexPath: newIndexPath!)
        case .Delete:
            self.fetchedResultsDelegate.deleteObject(indexPath!)
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch (type) {
        case .Insert:
            self.fetchedResultsDelegate.insertSection(sectionIndex)
        case .Delete:
            self.fetchedResultsDelegate.deleteSection(sectionIndex)
        default:
            assert(true, "change type \(type) should never been the case when section gets updated")
        }
    }
    

}
