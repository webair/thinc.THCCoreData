# Thinc CoreData
[![Build Status](https://api.travis-ci.org/webair/thinc.swift.THCCoreData.svg)](https://travis-ci.org/webair/thinc.swift.THCCoreData)

A Core Data wrapper written with Swift. 

# Usage
Make sure that all of you managed objects implements the protocol 'ManagedObjectEntity' and return its entity name.

You can also use [mogenerator](https://github.com/rentzsch/mogenerator) to generate this behaviour (Very nice tool, best thanks to the creators!). If using the mogenerator you need to add a base class which implements the 'ManagedObjectEntity' protocol or use my [fork](https://github.com/webair/mogenerator) which allowes you to add a protocol parameter and framework includes to the swift template:
    
    mogenerator --base-class-import "THCCoreData" \
                --protocol "ManagedObjectEntity" \
                ...

## Usage ContextManager
Get the default manager. It will create a sqlite store in the documents folder and merges all object model files from the main bundle
    let manager = ContextManager.defaultManager
    let artist = manager.mainContext.createObject(Artist.self)
        
If you need to change the default configuration you can set the used NSManagedObject and Store URL directly before calling the default manager the first time:
		  
    CoreDataConfiguration.defaultManagedObjectModel = NSManagedObjectModel(contentsOfURL:NSBundle.mainBundle().URLForResource("myModel", withExtension: "momd")!)
    CoreDataConfiguration.defaultStoreName = "myName"
    let manager = ContextManager.defaultManager
    let artist = manager.mainContext.createObject(Artist.self)
        
If you need a new private context, you can get it from the manager:

	let manager = ContextManager.defaultManager
	let privateContext = manager.privateContext

