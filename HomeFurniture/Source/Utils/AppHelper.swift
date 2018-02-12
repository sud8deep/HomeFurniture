//
//  AppHelper.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import Foundation
import UIKit

class AppHelper {
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private init() {}
}
