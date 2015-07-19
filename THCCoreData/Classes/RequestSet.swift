//
//  RequestSet.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

/**
Filer mode used for the filter function

- AND: AND filter
- OR:  OR filter
*/
public enum RequestFilterMode {
    case AND,OR
}
/**
Sort order used for the sortBy function

- ASCENDING:  sort ascending
- DESCENDING: sort desending
*/
public enum RequestSortOrder {
    case ASCENDING,DESCENDING
}

/**
*  Request set class, inspired by django QuerySet
*/
public class RequestSet<T:NSManagedObject>: SequenceType {
    
    private var objects:[NSManagedObject]?
    
    /// Used context for the request set
    public var context:NSManagedObjectContext
    
    public var count: Int {
        get{
            if let objects = self.objects {
                return objects.count
            }
            return self.context.countForFetchRequest(self.fetchRequest, error: nil)
        }
    }
    
    /// the currenty used fetch request, will return a copy
    private(set) public var fetchRequest: NSFetchRequest
    
    /**
    subscript for iterating over queryset
    
    - parameter index: index to access
    
    - returns: object at index
    */
    public subscript(index: Int) -> T {
        get {
            assert(index >= 0 && index < self.count, "Index out of range")
            self.fetchObjects()
            return self.objects![index] as! T
        }
    }
    
    /**
    Generator class for iterating
    
    - returns: Generator instance for iterating over object
    */
    public func generate() -> AnyGenerator<T> {
        self.fetchObjects()
        var nextIndex = 0
        return anyGenerator {
            if self.objects == nil || nextIndex == self.objects!.count {
                return nil
            }
            return self.objects![nextIndex++] as? T
        }
    }
    
    /**
    filter function
    
    - parameter predicate: filter predicate
    - parameter mode:      filter mode (default: FilterMode.AND)
    
    - returns: Instance of requestSet, used for chaining
    */
    public func filter(predicate:NSPredicate, mode:RequestFilterMode=RequestFilterMode.AND) -> Self {
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
    
    /**
    Filter function
    
    - parameter key:   key to filter
    - parameter value: value for key
    - parameter mode:  filter mode (default: FilterMode.AND)
    
    - returns: Instance of requestSet, used for chaining
    */
    public func filter(key:String, value:AnyObject, mode:RequestFilterMode=RequestFilterMode.AND) -> Self {
        let predicate = NSPredicate(format: "%K = %@", key, value as! NSObject)
        return self.filter(predicate, mode: mode)
    }
    
    /**
    Filter function
    
    - parameter filters: array of filter tuples
    - parameter mode:    filter mode (default: FilterMode.AND)
    
    - returns: Instance of requestSet, used for chaining
    */
    public func filter(filters: [(key:String, value:AnyObject)], mode:RequestFilterMode=RequestFilterMode.AND) -> Self {
        for filter in filters{
            self.filter(filter.key, value: filter.value)
        }
        return self
    }
    
    /**
    Sets the limit fot the requestSet
    
    - parameter limit: set the limit value
    
    - returns: Instance of requestSet, used for chaining
    */
    public func limit(limit:Int) -> Self {
        self.fetchRequest.fetchLimit = limit
        return self
    }
    
    /**
    Default initializer
    
    - parameter context: managed context used for request objects
    
    - returns: Instance of RequestSet
    */
    public init(context:NSManagedObjectContext) {
        self.context = context
        self.fetchRequest = self.context.fetchRequest(T)
    }
    
    /**
    Sets the sort descriptors for the request set
    
    - parameter key:   key to sort by
    - parameter order: defines the sort order (default: RequestSortOrder.ASCENDING)
    
    - returns: Instance of requestSet, used for chaini
    */
    public func sortBy(key:String, order:RequestSortOrder = RequestSortOrder.ASCENDING) -> Self {
        let ascending = order == RequestSortOrder.ASCENDING
        self.fetchRequest.sortDescriptors = [NSSortDescriptor(key:key, ascending: ascending)]
        return self
    }
    
    /**
    Sets multible sort descriptors
    
    - parameter sorts: array of sort tuples
    
    - returns:  Instance of requestSet, used for chaining
    */
    public func sortBy(sorts:[(key:String, order:RequestSortOrder)]) -> Self {
        var sortDescriptors: [NSSortDescriptor] = []
        for sort in sorts {
            let ascending = sort.order == RequestSortOrder.ASCENDING
            sortDescriptors.append(NSSortDescriptor(key:sort.key, ascending:ascending))
        }
        self.fetchRequest.sortDescriptors = sortDescriptors
        return self
    }
    
    /**
    Flushes the fetched objects, if any
    */
    public func flush() {
        self.objects = nil;
    }
    
    /**
    Resets the requestSet to the default state
    */
    public func reset() {
        self.fetchRequest = self.context.fetchRequest(T)
        self.flush()
    }
    
    private func fetchObjects() {
        if self.objects == nil {
            do {
                self.objects = try self.context.executeFetchRequest(self.fetchRequest) as? [NSManagedObject]
            } catch {
                self.objects = nil
            }

        }
    }
}
