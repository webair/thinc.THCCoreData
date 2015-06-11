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

    /// table view which will get updated
    public let tableView: UITableView
    
    /// internal fetchedResultsController which is used for updating the table view
    public var fetchedResultsController: NSFetchedResultsController
    
    /**
    Initializes a FetchedTableController
    
    :param: tableView      corresponding table view
    :param: fetchRequest   used fetch request
    :param: context        used context
    :param: sectionKeyPath section key path for section support
    
    :returns: initialized fetched table controller
    */
    public init(tableView: UITableView, fetchRequest: NSFetchRequest, context:NSManagedObjectContext, sectionKeyPath:String?=nil) {
        self.tableView = tableView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    /**
    Fetched the giben fetch request
    
    :returns: tuple if fetches succeeded
    */
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
    
    /**
    Number of section for the current fetch request
    
    :returns: number of section
    */
    public func numberOfSections() -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    /**
    
    :param: sectionIndex given section index
    
    :returns: number of objects for the given section index
    */
    public func numberOfRowsInSection(sectionIndex: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![sectionIndex] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    

}
