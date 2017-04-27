//
//  IAStringArchive.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 2/3/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import Foundation

/**
Provides an NSCoding complient wrapper for iaString, allowing IAString itself to remain pleasently non-objective C.
 */
open class IAStringArchive:NSObject, NSCoding {
    
    open let iaString:IAString
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        guard let dict = aDecoder.decodeObject(forKey: "iaStringDictArchive") as? [String:Any] else {self.iaString = IAString();super.init();return nil}
        guard let newIAString = IAString(dict: dict) else {self.iaString = IAString();super.init();return nil}
        self.iaString = newIAString
        super.init()
    }
    
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(iaString.convertToAlmostJSONReadyDict(), forKey: "iaStringDictArchive")
    }
    
    public init(iaString:IAString){
        self.iaString = iaString
        super.init()
    }
    
    
    open static func archive(_ iaString:IAString)->Data{
        let archive = IAStringArchive(iaString: iaString)
        return NSKeyedArchiver.archivedData(withRootObject: archive)
    }
    
    open static func unarchive(_ data:Data)->IAString?{
        guard let archive = NSKeyedUnarchiver.unarchiveObject(with: data) as? IAStringArchive else { return nil}
        return archive.iaString
    }
    
}

