//
//  CoreDataTestCase.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import UIKit
import XCTest
import THCCoreData
import CoreData

class CoreDataTestCase: XCTestCase {

    var manager: ContextManager = {
        let objectModelURL = NSBundle(forClass: CoreDataTestCase.self).URLForResource("Model", withExtension: "momd")!
        let objectModel = NSManagedObjectModel(contentsOfURL: objectModelURL)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        do {
            try coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch _ {
        }
        return ContextManager(persistentStoreCoordinator: coordinator)
    }()
}
