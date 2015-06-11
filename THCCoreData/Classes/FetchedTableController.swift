//
//  File.swift
//  THCCoreData
//
//  Created by Christopher weber on 08.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public class FetchedTableController: NSObject, NSFetchedResultsControllerDelegate {

    public let tableView: UITableView
    
    public var fetchedResultsController: NSFetchedResultsController
    
    public init(tableView: UITableView, fetchRequest: NSFetchRequest, context:NSManagedObjectContext, sectionKeyPath:String?=nil) {
        self.tableView = tableView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    public func fetch() -> (success:Bool, error: NSError?) {
        var error: NSError?
        let success = self.fetchedResultsController.performFetch(&error)
        return (success, error)
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            assert(true, "change type \(type) should never been the case when section gets updated")
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    public func numberOfSections() -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    public func numberOfRowsInSection(sectionIndex: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![sectionIndex] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    

}
