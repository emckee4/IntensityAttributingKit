//
//  IAKitOptions.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 12/1/15.
//  Copyright © 2015 McKeeMaKer. All rights reserved.
//

import Foundation


/**
IAKitOptions is the internal singleton for the text kit which caches keyboard and stores settings which need to be persisted across sessions
*/
class IAKitOptions:NSObject, NSCoding {
    
    
    ///singleton for IAKitOptions. Attempts to recover a saved instance of itself from NSUserDefaults on init, initializing with default values otherwise.
    static let singleton:IAKitOptions = {
        if let existingValue = NSUserDefaults.standardUserDefaults().objectForKey("iaKitOptions") as? IAKitOptions {
            return IAKitOptions()
        }
        return IAKitOptions()
    }()
        ///setter/getter for retrieving from storage
    
    //MARK:- Keyboard and accessory caching
    private var vcCache:NSCache

    var keyboard:IAKeyboard {
        if let kb = vcCache.objectForKey("iaKB") as? IAKeyboard {
            return kb
        } else {
            let kb = IAKeyboard(nibName:nil, bundle: nil)
            vcCache.setObject(kb, forKey: "iaKB")
            return kb
        }
    }
    
    var accessory:IAAccessoryVC {
        if let acc = vcCache.objectForKey("iaAccessory") as? IAAccessoryVC {
            return acc
        } else {
            let acc = IAAccessoryVC(nibName:nil, bundle: nil)
            vcCache.setObject(acc, forKey: "iaAccessory")
            return acc
        }
    }
    
    ///flushes the cache containing the keyboard and accessory so that they'll be recreated on the next access request
    func resetKBAndAccessory(){
        vcCache.removeAllObjects()
    }
    
    //// store retained options/defaults here
    
    var defaultIntensity:Float = 0.4
    var defaultTextSize:CGFloat = 20.0
    var defaultScheme:IntensityTransformers = IntensityTransformers.WeightScheme
    
    var maxSavedImageDimensions:CGSize = CGSize(width: 640, height: 640)
    
    
    ////
    
    private override init(){
        vcCache = NSCache()
    }
    
    
    //add nscoding stuff
    
    required init?(coder aDecoder: NSCoder) {
        vcCache = NSCache()

    }
    
    func encodeWithCoder(aCoder: NSCoder) {

    }
    
    
    
    
}