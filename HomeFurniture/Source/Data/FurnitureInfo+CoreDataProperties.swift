//
//  FurnitureInfo+CoreDataProperties.swift
//  HomeFurniture
//
//  Created by sudeep.r on 12/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//
//

import Foundation
import CoreData


extension FurnitureInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FurnitureInfo> {
        return NSFetchRequest<FurnitureInfo>(entityName: "FurnitureInfo")
    }

    @NSManaged public var detail: String?
    @NSManaged public var imageData: NSData?
    @NSManaged public var title: String?
    @NSManaged public var modelManager: FurnitureModelManager?

}
