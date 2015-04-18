//
//  RequestSet.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public enum FilterMode {
    case AND,OR
}

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
    
    private(set) public var fetchRequest: NSFetchRequest
    
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
    
    public func filter(predicate:NSPredicate, mode:FilterMode=FilterMode.AND) -> Self {
        //TODO: validate predicate
        if let fetchPredicate = self.fetchRequest.predicate {
            switch (mode) {
                case .AND:
                    self.fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([fetchPredicate, predicate])
                case .OR:
                    self.fetchRequest.predicate = NSCompoundPredicate.orPredicateWithSubpredicates([fetchPredicate, predicate])
            }
        } else {
            self.fetchRequest.predicate = predicate
        }
        return self
    }
    
    public func filter(filter: (key:String,value:AnyObject), mode:FilterMode=FilterMode.AND) -> Self {
        let predicate = NSPredicate(format: "%K = %@", filter.key, filter.value as! NSObject)
        return self.filter(predicate, mode: mode)
    }
    
    public func filter(filters: [(key:String, value:AnyObject)], mode:FilterMode=FilterMode.AND) -> Self {
        for filter in filters{
            self.filter(filter)
        }
        return self
    }
    
    public func limit(limit:Int) -> Self {
        self.fetchRequest.fetchLimit = limit
        return self
    }
    
    public init(context:NSManagedObjectContext) {
        self.context = context
        self.fetchRequest = self.context.fetchRequest(T)
    }
    
    public func sortBy(key:String, ascending: Bool=true) -> Self {
        self.fetchRequest.sortDescriptors = [NSSortDescriptor(key:key, ascending: ascending)]
        return self
    }
    
    public func sortBy(sorts:[(key:String, ascending: Bool)]) -> Self {
        var sortDescriptors: [NSSortDescriptor] = []
        for sort in sorts {
            sortDescriptors.append(NSSortDescriptor(key:sort.key, ascending: sort.ascending))
        }
        self.fetchRequest.sortDescriptors = sortDescriptors
        return self
    }
    
    private func fetchObjects() {
        if self.objects == nil {
            var error:NSError?
            self.objects = self.context.executeFetchRequest(self.fetchRequest, error: &error) as? [NSManagedObject]
        }
    }
}
