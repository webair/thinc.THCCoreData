//
//  StubObject.swift
//  THCCoreData
//
//  Created by Christopher weber on 08.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData
import THCCoreData


class StubObject: NSManagedObject, NamedManagedObject {
    
    class func entityName() -> String {
        return "StubEntity"
    }
    
    @NSManaged var name: String

}
