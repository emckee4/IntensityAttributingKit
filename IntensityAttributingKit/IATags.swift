import UIKit

public struct IATags {
    public static let IAKeys = "IAKeys"
    public static let IAIntensity = "IAIntensity"
    public static let IASize = "IASize"
    public static let IABold = "IABold"
    public static let IAItalic = "IAItalic"
    public static let IAUnderline = "IAUnderline"
    public static let IAStrikethrough = "IAStrikethrough"
    public static let IACurrentRendering = "IACurrentRendering"
    
    public static var allTags:[String] {
        return [IAIntensity, IASize, IABold, IAItalic, IAUnderline, IAStrikethrough, IACurrentRendering]
    }
    public static var mandatoryTags:[String] {
        return [IAIntensity, IASize]
    }
    public static var optionalTags:[String] {
        return [IABold, IAItalic, IAUnderline, IAStrikethrough, IACurrentRendering]
    }
    
    
    public static func partitionAttributeDict(attrs:[String:AnyObject])->(iaDict:[String:AnyObject],nonIADict:[String:AnyObject],attachment:NSTextAttachment?, anyLink:AnyObject?){
        var nonIADict:[String:AnyObject] = attrs
        
        let attachment = nonIADict.removeValueForKey(NSAttachmentAttributeName) as? NSTextAttachment
        let anyLink = nonIADict.removeValueForKey(NSFontAttributeName)
        let iaDict:[String:AnyObject] = (nonIADict.removeValueForKey(IATags.IAKeys) as? [String:AnyObject]) ?? [:]
        
        return (iaDict:iaDict, nonIADict:nonIADict, attachment:attachment, anyLink:anyLink)
    }
    
    
    
}

