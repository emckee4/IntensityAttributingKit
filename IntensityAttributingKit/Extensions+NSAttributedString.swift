import UIKit


public extension NSMutableAttributedString {
    ///Strips nonIA attributes (other than attachments and links), then applies IAAttributes of the supplied IntensityAttributes
    func applyIntensityAttributes(attributes:IntensityAttributes, toRange:NSRange! = nil, onlyToUnattributed:Bool = false){
        let range = toRange ?? NSRange(location: 0, length: self.length)
        //        //first remove optional tags
        //        for iaTag in IATags.optionalTags {
        //            self.removeAttribute(iaTag, range: range)
        //        }
        //        //check for any text attachments that need to be saved:
        //        var attachments:[Int:NSTextAttachment] = [:]
        //        self.enumerateAttribute(NSAttachmentAttributeName, inRange: range, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired) { (value:AnyObject?, attRange:NSRange, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
        //            if let attachment = value as? NSTextAttachment {
        //                attachments[attRange.location] = attachment
        //                if attRange.length != 1 {
        //                    print("enumerateAttribute: length of textAttachment attributed != 1: \(attRange.length)")
        //                }
        //            }
        //        }
        //        ///now apply all attributes over the range
        //        self.setAttributes(attributes.asAttributeDict, range: range)
        //        for (index,attachment) in attachments {
        //            self.addAttribute(NSAttachmentAttributeName, value: attachment, range: NSRange(location: index, length: 1))
        //        }
        
        
        self.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions.init(rawValue: 0)) { (var attrs:[String : AnyObject], enumRange:NSRange, stop) -> Void in
            if onlyToUnattributed == false || attrs[IATags.IAKeys] == nil {
                //replace
                let attachment:NSTextAttachment? = attrs[NSAttachmentAttributeName] as? NSTextAttachment
                let anyLink:AnyObject? = attrs[NSLinkAttributeName]

                var newDict:[String:AnyObject] = [IATags.IAKeys:attributes.asAttributeDict]
                if attachment != nil {
                    newDict[NSAttachmentAttributeName] = attachment!
                }
                if anyLink != nil {
                    newDict[NSLinkAttributeName] = anyLink!
                }
                self.setAttributes(newDict, range: enumRange)
            }
        }
    }
    
    
    func transformWithRenderSchemeInPlace(schemeName: String){
        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return}
        guard let transformer = IntensityTransformers(rawValue: schemeName)?.transformer
            else {fatalError("transformWithRenderSchemeInPlace received unknown schemeName parameter: \(schemeName)")}
        transformer.transformWithSchemeInPlace(targetIAString: self)
    }
    
    
    
}



public extension NSAttributedString {
    //verifies that every element in string has IAIntensity and IASize. Maybe add IACurrentRendering???
    func isFullyIntensityAttributed(checkMatchingScheme:Bool = false)->Bool{
        for i in 0..<self.length {
            let atts = self.attributesAtIndex(i, effectiveRange: nil)
            guard atts[IATags.IAKeys] != nil else {return false }//atts.keys.contains(IATags.IAIntensity) && atts.keys.contains(IATags.IASize) else {return false}
        }
        return true
    }
    
    
    
    //transform
    func transformWithRenderScheme(schemeName:String)->NSAttributedString!{
        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return nil}
        guard let transformer = IntensityTransformers(rawValue: schemeName)?.transformer
            else {fatalError("transformWithRenderScheme received unknown schemeName parameter: \(schemeName)")}
        return transformer.transformWithScheme(targetIAString: self)
    }
    
    
    
    convenience init(attributedString:NSAttributedString, defaultAttributes:IntensityAttributes, overwriteAttributes:Bool = false, renderWithScheme:String! = nil){
        
        let mutableAS = NSMutableAttributedString(attributedString: attributedString)
        
        mutableAS.applyIntensityAttributes(defaultAttributes, onlyToUnattributed: !overwriteAttributes)
        
        if let scheme = renderWithScheme as String? {
            mutableAS.transformWithRenderSchemeInPlace(scheme)
        }
        self.init(attributedString: mutableAS)
    }
    
    convenience init(string:String, defaultAttributes:IntensityAttributes, renderWithScheme:String! = nil){
        let mutableAS = NSMutableAttributedString(string: string, attributes:[IATags.IAKeys :defaultAttributes.asAttributeDict])
        
        if let scheme = renderWithScheme as String? {
            mutableAS.transformWithRenderSchemeInPlace(scheme)
        }
        self.init(attributedString: mutableAS)
    
    }
    
    ///initializes an NSAttributedString with an image attachment, performing requisite scaling, bounds adjustment, and application of intensity attributes
    convenience init(image:UIImage, intensityAttributes:IntensityAttributes, displayMaxSize:CGSize, cropToMaxSize:CGSize) {
            let attachment = NSTextAttachment()
            attachment.image = image.resizeImageToFit(maxSize: cropToMaxSize)
            let imageSize = attachment.image!.size
            let displaySize = image.size.sizeThatFitsMaintainingAspect(containerSize: displayMaxSize)
            attachment.bounds = CGRect(origin: CGPointZero, size: displaySize)
            var iaAttributes = intensityAttributes.asAttributeDict
            iaAttributes[IATags.IAAttachmentSize] = ["w":imageSize.width,"h":imageSize.height]
            let attributes = [NSAttachmentAttributeName:attachment, IATags.IAKeys: iaAttributes]
            self.init(string: "\u{FFFC}", attributes: attributes)
    }
    
    
}
