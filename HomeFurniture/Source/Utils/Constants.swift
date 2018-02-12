//
//  Constants.swift
//  HomeFurniture
//
//  Created by sudeep.r on 12/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import Foundation
import UIKit

class AppConstants {
    static let imageCompressionRatio: CGFloat = 0.4
    
    private init() {}
}

class CoreDataConstants {
    static let dataModel = "HomeFurniture"
    static let coreDataFile = dataModel + ".sqlite"
    static let furnitureModelManager = "FurnitureModelManager"
    static let furnitureInfo = "FurnitureInfo"
    static let mmFurnitureMember = "furnitureInfoSet"
    
    private init() {}
}

class AlertConstants {
    static let addFurniture = "Add furniture"
    static let chooseImageFrom = "Choose image from"
    static let capturePhoto = "Capture photo"
    static let photoLibrary = "Photos Library"
    static let editFurniture = "Edit this furniture info"
    static let deleteFurniture = "Delete this furniture info"
    static let error = "Error"
    static let enterTitle = "Please Enter Title"
    static let noImage = "No Image found"
    static let warning = "Warning"
    static let furnitureWithThisTitleExists = "Furniture with this title exists"
    static let addDuplicate = "Add Duplicate"
    static let replace = "Replace"
    static let cancel = "Cancel"
    static let noCameraOnDevice = "No Camera found on this device!!!"
    static let editFurnitureImage = "Edit Furniture Image"
    
    private init() {}
}
