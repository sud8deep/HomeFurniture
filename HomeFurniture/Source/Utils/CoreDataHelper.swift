//
//  CoreDataHelper.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {
    var modelManager: FurnitureModelManager!
    
    private static var sInstance : CoreDataHelper!
    
    static var persistantContainer: NSPersistentContainer = {
        return AppHelper.getAppDelegate().persistentContainer
    }()
    
    static var managedContext: NSManagedObjectContext = {
        return CoreDataHelper.persistantContainer.viewContext
    }()
    
    static func saveContext() {
        DispatchQueue.main.async {
            AppHelper.getAppDelegate().saveContext()
        }
    }
    
    class func shared() -> CoreDataHelper {
        if (sInstance == nil) {
            sInstance = CoreDataHelper()
        }
        return sInstance
    }
    
    class func destroyInstance() {
        sInstance = nil
    }
    
    private init() {
        initializeCoreDataHelper()
    }
    
    private func initializeCoreDataHelper() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.furnitureModelManager)
        do {
            let fetchedObjects = try CoreDataHelper.managedContext.fetch(fetchRequest) as! [FurnitureModelManager]
            if (fetchedObjects.count == 0) {        //No DB
                self.modelManager = FurnitureModelManager(context: CoreDataHelper.managedContext)
            }
            else{
                self.modelManager = fetchedObjects.first!
            }
        } catch {
            self.modelManager = FurnitureModelManager(context: CoreDataHelper.managedContext)
        }
    }
    
    func removeFurniture(info: FurnitureInfo) {
        modelManager.removeFromFurnitureInfoSet(info)
        CoreDataHelper.managedContext.delete(info)
        CoreDataHelper.saveContext()
    }
    
    func removeAllFurnitureWithTitle(title: String) {
        let mutableOrderedSet = modelManager.mutableOrderedSetValue(forKey: CoreDataConstants.mmFurnitureMember)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.furnitureInfo)
        fetchRequest.predicate = NSPredicate(format: "title ==[c] %@", title)
        do {
            let fetchedObjects = try CoreDataHelper.managedContext.fetch(fetchRequest) as! [FurnitureInfo]
            for furnitureToRemove in fetchedObjects {
                mutableOrderedSet.remove(furnitureToRemove)
                CoreDataHelper.managedContext.delete(furnitureToRemove)
            }
        } catch {
            
        }
        CoreDataHelper.saveContext()
    }
    
    func addFurnitureInfo(title: String, details: String?, imageData: Data) -> FurnitureInfo {
        let furnitureInfo = FurnitureInfo(context: CoreDataHelper.managedContext)
        furnitureInfo.title = title
        furnitureInfo.detail = details
        furnitureInfo.imageData = imageData
        furnitureInfo.timeStamp = Date()
        CoreDataHelper.shared().modelManager.addToFurnitureInfoSet(furnitureInfo)
        CoreDataHelper.saveContext()
        return furnitureInfo
    }
    
    internal func isPresent(furnitureWithTitle: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.furnitureInfo)
        fetchRequest.predicate = NSPredicate(format: "title ==[c] %@", furnitureWithTitle)
        
        var isPresent = false
        do {
            let fetchedObjects = try CoreDataHelper.managedContext.fetch(fetchRequest) as! [FurnitureInfo]
            if fetchedObjects.count > 0 {
                isPresent = true
            }
        } catch {}
        
        return isPresent
    }
}

