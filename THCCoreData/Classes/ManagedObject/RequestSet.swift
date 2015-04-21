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
public enum FilterMode {
    case AND,OR
}

/**
*  Request set class, inspired by django QuerySet
*/
public class RequestSet<T:NamedManagedObject>: SequenceType {
    
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
    
    private(set) public var fetchRequest: NSFetchRequest
    
    /**
    subscript for iterating over queryset
    
    :param: index index to access
    
    :returns: object at index
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
    
    :returns: Generator instance for iterating over object
    */
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
    
    /**
    filter function
    
    :param: predicate filter predicate
    :param: mode      filter mode (default: FilterMode.AND)
    
    :returns: Instance of requestSet, used for chaining
    */
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
    
    /**
    Filter function
    
    :param: key   key to filter
    :param: value value for key
    :param: mode  filter mode (default: FilterMode.AND)
    
    :returns: Instance of requestSet, used for chaining
    */
    public func filter(key:String, value:AnyObject, mode:FilterMode=FilterMode.AND) -> Self {
        let predicate = NSPredicate(format: "%K = %@", key, value as! NSObject)
        return self.filter(predicate, mode: mode)
    }
    
    /**
    Filter function
    
    :param: filters array of filter tuples
    :param: mode    filter mode (default: FilterMode.AND)
    
    :returns: Instance of requestSet, used for chaining
    */
    public func filter(filters: [(key:String, value:AnyObject)], mode:FilterMode=FilterMode.AND) -> Self {
        for filter in filters{
            self.filter(filter.key, value: filter.value)
        }
        return self
    }
    
    /**
    Sets the limit fot the requestSet
    
    :param: limit set the limit value
    
    :returns: Instance of requestSet, used for chaining
    */
    public func limit(limit:Int) -> Self {
        self.fetchRequest.fetchLimit = limit
        return self
    }
    
    /**
    Default initializer
    
    :param: context manage context used for request objects
    
    :returns: Instance of RequestSet
    */
    public init(context:NSManagedObjectContext) {
        self.context = context
        self.fetchRequest = self.context.fetchRequest(T)
    }
    
    /**
    Sets the sort descriptors
    
    :param: key       key to sort
    :param: ascending True if sort is ascending (default: True)
    
    :returns: Instance of requestSet, used for chaining
    */
    public func sortBy(key:String, ascending: Bool=true) -> Self {
        self.fetchRequest.sortDescriptors = [NSSortDescriptor(key:key, ascending: ascending)]
        return self
    }
    
    /**
    Sets multible sort descriptors
    
    :param: sorts array of sort tuples
    
    :returns:  Instance of requestSet, used for chaining
    */
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
