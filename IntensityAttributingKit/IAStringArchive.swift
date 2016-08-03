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
public class IAStringArchive:NSObject, NSCoding {
    
    public let iaString:IAString
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        guard let dict = aDecoder.decodeObjectForKey("iaStringDictArchive") as? [String:AnyObject] else {self.iaString = IAString();super.init();return nil}
        guard let newIAString = IAString(dict: dict) else {self.iaString = IAString();super.init();return nil}
        self.iaString = newIAString
        super.init()
    }
    
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(iaString.convertToAlmostJSONReadyDict(), forKey: "iaStringDictArchive")
    }
    
    public init(iaString:IAString){
        self.iaString = iaString
        super.init()
    }
    
    
    public static func archive(iaString:IAString)->NSData{
        let archive = IAStringArchive(iaString: iaString)
        return NSKeyedArchiver.archivedDataWithRootObject(archive)
    }
    
    public static func unarchive(data:NSData)->IAString?{
        guard let archive = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? IAStringArchive else { return nil}
        return archive.iaString
    }
    
}

