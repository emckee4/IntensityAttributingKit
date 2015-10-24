
import UIKit

public protocol IntensityTransforming {
    static var schemeName:String {get}
    ///nsAttributesForIAAttributes provides the must be implemented by each transforming class as it holds the meat of the class specific conversion
    func nsAttributesForIAAttributes(iaAttributes:[String:AnyObject])->[String:AnyObject]
    func transformWithScheme(targetIAString attString:NSAttributedString)->NSAttributedString
    func transformWithSchemeInPlace(targetIAString attString:NSMutableAttributedString)
}

///Default implementations for the mutable and immutable transformations. These each rely on nsAttributesForIAAttributes to do the scheme specific work.
public extension IntensityTransforming {
    func transformWithScheme(targetIAString attString: NSAttributedString) -> NSAttributedString {
        let mutAS = NSMutableAttributedString(attributedString: attString)
        transformWithSchemeInPlace(targetIAString: mutAS)
        return NSAttributedString(attributedString: mutAS)
    }
    
    func transformWithSchemeInPlace(targetIAString attString: NSMutableAttributedString) {
        attString.enumerateAttributesInRange(NSRange(location: 0, length: attString.length), options: NSAttributedStringEnumerationOptions.init(rawValue: 0)) { (attrs:[String : AnyObject], range:NSRange, stop) -> Void in
            let partedAtts = IATags.partitionAttributeDict(attrs)
            let newNSAtts = self.nsAttributesForIAAttributes(partedAtts.iaDict)
            var newCombinedAttrs:[String:AnyObject] = partedAtts.iaDict
            for (key,value) in newNSAtts {
                newCombinedAttrs[key] = value
            }
            if partedAtts.attachment != nil {
                newCombinedAttrs[NSAttachmentAttributeName] = partedAtts.attachment!
            }
            if partedAtts.anyLink != nil {
                newCombinedAttrs[NSLinkAttributeName] = partedAtts.anyLink!
            }
            newCombinedAttrs[IATags.IACurrentRendering] = Self.schemeName
            ///check if the attributes still match after the transform. If so we don't need to setAttributes on this entry
            if (newCombinedAttrs as! [String:NSObject]) != (attrs as! [String:NSObject])  {
                attString.setAttributes(newCombinedAttrs, range: range)
            }
        }
    }
    
}
