# Thinc CoreData
[![Build Status](https://api.travis-ci.org/webair/thinc.swift.THCCoreData.svg)](https://travis-ci.org/webair/thinc.swift.THCCoreData)

A Core Data wrapper written with Swift. 

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

