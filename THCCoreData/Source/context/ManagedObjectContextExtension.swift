//
//  ManageObjectContextExtension.swift
//  THCCoreData
//
//  Created by Christopher weber on 06.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectEntity {
    /**
    return the entity name of the managed object (will be changed to a class var, as soon this is possible in swift)
    
    :returns: Entity name defined in the object model
    */
    static func entityName() -> String
}

public extension NSManagedObjectContext {
    
    /**
    Creates a instance of the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of the created ManagedObject
    */
    public func createObject<T:ManagedObjectEntity>(objectType: T.Type) -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(objectType.entityName(), inManagedObjectContext: self) as! T
    }
    
    /**
    Creates a fetch request for the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of a fetch request for the given obejct type
    */
    public func fetchRequest<T:ManagedObjectEntity>(objectType: T.Type) -> NSFetchRequest {
        return NSFetchRequest(entityName: objectType.entityName())
    }
    
    /**
    Creates a request set for the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of a request set for the given obejct type
    */
    public func requestSet<T:ManagedObjectEntity>(objectType: T.Type) -> RequestSet<T> {
        return RequestSet<T>(context: self)
    }
    
}
