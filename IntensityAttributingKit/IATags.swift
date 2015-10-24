import UIKit

public struct IATags {
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
        let attachment = attrs[NSAttachmentAttributeName] as? NSTextAttachment
        let anyLink = attrs[NSLinkAttributeName]
        var iaDict:[String:AnyObject] = [:]
        var nonIADict:[String:AnyObject] = [:]
        for key in attrs.keys {
            if allTags.contains(key){
                iaDict[key] = attrs[key]
            } else if key != NSAttachmentAttributeName && key != NSLinkAttributeName {
                nonIADict[key] = attrs[key]
            }
        }
        return (iaDict:iaDict, nonIADict:nonIADict, attachment:attachment, anyLink:anyLink)
    }
}

