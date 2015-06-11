//
//  StubObject.swift
//  THCCoreData
//
//  Created by Christopher weber on 09.05.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

class StubObject: NSManagedObject {

    @NSManaged var name: String
    
    override class func entityName() -> String {
        return "StubEntity"
    }

}
