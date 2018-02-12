//
//  FurnitureModelManager+CoreDataProperties.swift
//  HomeFurniture
//
//  Created by sudeep.r on 12/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//
//

import Foundation
import CoreData


extension FurnitureModelManager {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FurnitureModelManager> {
        return NSFetchRequest<FurnitureModelManager>(entityName: "FurnitureModelManager")
    }

    @NSManaged public var furnitureInfoSet: NSOrderedSet?

}

// MARK: Generated accessors for furnitureInfoSet
extension FurnitureModelManager {

    @objc(insertObject:inFurnitureInfoSetAtIndex:)
    @NSManaged public func insertIntoFurnitureInfoSet(_ value: FurnitureInfo, at idx: Int)

    @objc(removeObjectFromFurnitureInfoSetAtIndex:)
    @NSManaged public func removeFromFurnitureInfoSet(at idx: Int)

    @objc(insertFurnitureInfoSet:atIndexes:)
    @NSManaged public func insertIntoFurnitureInfoSet(_ values: [FurnitureInfo], at indexes: NSIndexSet)

    @objc(removeFurnitureInfoSetAtIndexes:)
    @NSManaged public func removeFromFurnitureInfoSet(at indexes: NSIndexSet)

    @objc(replaceObjectInFurnitureInfoSetAtIndex:withObject:)
    @NSManaged public func replaceFurnitureInfoSet(at idx: Int, with value: FurnitureInfo)

    @objc(replaceFurnitureInfoSetAtIndexes:withFurnitureInfoSet:)
    @NSManaged public func replaceFurnitureInfoSet(at indexes: NSIndexSet, with values: [FurnitureInfo])

    @objc(addFurnitureInfoSetObject:)
    @NSManaged public func addToFurnitureInfoSet(_ value: FurnitureInfo)

    @objc(removeFurnitureInfoSetObject:)
    @NSManaged public func removeFromFurnitureInfoSet(_ value: FurnitureInfo)

    @objc(addFurnitureInfoSet:)
    @NSManaged public func addToFurnitureInfoSet(_ values: NSOrderedSet)

    @objc(removeFurnitureInfoSet:)
    @NSManaged public func removeFromFurnitureInfoSet(_ values: NSOrderedSet)

}
