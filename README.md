# Thinc CoreData
[![Build Status](https://api.travis-ci.org/webair/thinc.swift.THCCoreData.svg)](https://travis-ci.org/webair/thinc.swift.THCCoreData)

A Core Data Extension written with Swift. 

# Usage
Make sure that all of you managed objects implements the protocol 'NamedManageObject' and return its entity name.

You can also use [mogenerator](https://github.com/rentzsch/mogenerator) to generate this behaviour (Very nice tool, best thanks to the creators!). If using the mogenerator you need to add a base class which implements the 'ManagedObjectEntity' protocol or use my [fork](https://github.com/webair/mogenerator) which allowes you to add a protocol parameter and framework includes to the swift template:
    
    mogenerator --base-class-import "THCCoreData" \
                --protocol "ManagedObjectEntity" \
                ...

## ContextManager
Get the default manager. It will create a sqlite store in the documents folder and merges all object model files from the main bundle.  

    let manager = ContextManager.defaultManager
    let mainContext = manager.mainContext
If you need a new private context, you can get it from the manager:
    let privateContext = manager.privateContext
        
If you need to change the default configuration you can set the used NSManagedObject and Store URL directly before calling the default manager the first time:
		  
    CoreDataConfiguration.defaultManagedObjectModel = NSManagedObjectModel(contentsOfURL:NSBundle.mainBundle().URLForResource("myModel", withExtension: "momd")!)
    CoreDataConfiguration.defaultStoreName = "myName"
    let manager = ContextManager.defaultManager
	
## NSManagedContext
This library extends the default NSManagedObjectContext class. Assume we have generated a managed object subclass 'MyObject' from an entity, you can now insert it to the context like that:

    let context = ContextManager.defaultManager.mainContext
    let myObject = context.createObject(MyObject)
    
You can also get a default NSFetchRequest for a given managed object subclass:
    
    let fetchRequest = context.fetchRequest(MyObject)
    
Last but no least you can also get a RequestSet (see RequestSet) class from the context:

	let requestSet = context.requestSet(MyObject)
 
## RequestSet

This class was inspired by the django framework for python (QuerySet). It helps create a NSFetchRequest and let you easily create fetch requests.

### Filters

    let requestSet = context.requestSet(MyObject)
    // iterate over result set
    for object in requestSet:
      println("name \(object.name)")
    
    // filter with predicate
    requestSet.filter(NSPredicate(format:name=%@, "Value"))
    
    // simple filters
    requestSet.filter((key:"name", value:"Test"))
    // will create "name='Test'" predicate
    
    // list filters
    requestSet.filter([(key:"name", value:"Test"), (key:"otherName", value:"Test")])
    // will create "name='Test' AND otherName='Test'" predicate

	// chain filters
	requestSet.filter((key:"name", value:"Test"))
	requestSet.filter((key:"otherName", value:"Test"))
	// will create "name='Test' AND otherName='Test'" predicate
	
	// OR filter
		requestSet.filter((key:"name", value:"Test"))
	requestSet.filter((key:"otherName", value:"Test"), mode=FilterMode.OR)
	// will create "name='Test' OR otherName='Test'" predicate
	