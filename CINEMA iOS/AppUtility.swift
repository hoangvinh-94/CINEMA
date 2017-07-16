//
//  AppUtility.swift
//  CINEMA iOS
//
//  Created by TTB on 6/25/17.
//  Copyright © 2017 healer. All rights reserved.
//

import Foundation


//  This class use to lock Orientation of the screen
class AppUtility {
    
    // function lock the rotate of screen
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation") // Change the current orientation to parameter "orientation"
    }
    
}
