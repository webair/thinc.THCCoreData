//
//  ManageObjectContextExtension.swift
//  THCCoreData
//
//  Created by Christopher weber on 06.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    
    /**
    Creates a instance of the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of the created ManagedObject
    */
    public func createObject<T:NSManagedObject>(objectType: T.Type) -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(objectType.entityName(), inManagedObjectContext: self) as! T
    }
    
    /**
    Creates a fetch request for the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of a fetch request for the given obejct type
    */
    public func fetchRequest<T:NSManagedObject>(objectType: T.Type) -> NSFetchRequest {
        return NSFetchRequest(entityName: objectType.entityName())
    }
    
    /**
    Creates a request set for the given ManagedObject class
    
    :param: objectType Type of the managed object
    
    :returns: Instance of a request set for the given obejct type
    */
    public func requestSet<T:NSManagedObject>(objectType: T.Type) -> RequestSet<T> {
        return RequestSet<T>(context: self)
    }
    /**
    Persists context, will invoke parent contexts if any
    
    :param: success success closure
    */
    public func persist(completion: ((success:Bool, error:NSError?) -> Void)?) {
        
        let persistClosure: () -> () = {
            var error: NSError?
            if self.save(&error) {
                if let parentContext = self.parentContext {
                    parentContext.persist(completion)
                } else {
                    completion?(success: true, error: error)
                }
            } else {
                completion?(success: false, error: error)
            }
        }
        
        if (self.parentContext != nil) {
            self.performBlockAndWait(persistClosure)
        } else {
            self.performBlock(persistClosure)
        }
        
        
    }
    
}
