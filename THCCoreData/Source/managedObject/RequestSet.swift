//
//  RequestSet.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public class RequestSet<T:ManagedObjectEntity>: SequenceType {
    
    private var objects:[NSManagedObject]?
    public var context:NSManagedObjectContext
    
    public var count: Int {
        get{
            if let objects = self.objects {
                return objects.count
            }
            return self.context.countForFetchRequest(self.fetchRequest, error: nil)
        }
    }
    
    public var fetchRequest: NSFetchRequest {
        get{
            let fetchRequest = self.context.fetchRequest(T)
            return fetchRequest;
        }
    }
    
    public subscript(index: Int) -> T {
        get {
            assert(index >= 0 && index < self.count, "Index out of range")
            self.fetchObjects()
            return self.objects![index] as! T
        }
    }
    
    public func generate() -> GeneratorOf<T> {
        self.fetchObjects()
        var nextIndex = 0
        return GeneratorOf<T> {
            if self.objects == nil || nextIndex == self.objects!.count {
                return nil
            }
            return self.objects![nextIndex++] as? T
        }
    }
    
    public init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchObjects() {
        if self.objects == nil {
            var error:NSError?
            self.objects = self.context.executeFetchRequest(self.fetchRequest, error: &error) as? [NSManagedObject]
        }
    }
}
