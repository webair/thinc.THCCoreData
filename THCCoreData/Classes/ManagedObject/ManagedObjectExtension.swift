//
//  ManagedObjectExtension.swift
//  THCCoreData
//
//  Created by Christopher weber on 09.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    public class func entityName() -> String! {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public class func entity(context: NSManagedObjectContext) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context);
    }
    
    public class func create(context: NSManagedObjectContext) -> Self {
        return context.createObject(self)
    }
}
