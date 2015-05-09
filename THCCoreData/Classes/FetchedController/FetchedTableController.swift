//
//  File.swift
//  THCCoreData
//
//  Created by Christopher weber on 08.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public class FetchedTableController {

    public let tableView: UITableView
    
    public let fetchedResultsController: NSFetchedResultsController
    
    public init(tableView: UITableView, fetchRequest: NSFetchRequest, context:NSManagedObjectContext, sectionKeyPath:String?=nil) {
        self.tableView = tableView
        // TODO find a good way to handle cache, maby hash or fetchrequest??
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        //self.fetchedResultsController.delegate = self
        
    }
    
    

}
