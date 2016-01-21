import UIKit


public extension NSMutableAttributedString {
    ///Strips nonIA attributes (other than attachments and links), then applies IAAttributes of the supplied IntensityAttributes
    func applyIntensityAttributes(attributes:IntensityAttributes, toRange:NSRange! = nil, onlyToUnattributed:Bool = false){
        let range = toRange ?? NSRange(location: 0, length: self.length)
        self.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions.init(rawValue: 0)) { (var attrs:[String : AnyObject], enumRange:NSRange, stop) -> Void in
            if onlyToUnattributed == false || attrs[IATags.IAKeys] == nil {
                //replace
                let attachment:IATextAttachment? = attrs[NSAttachmentAttributeName] as? IATextAttachment
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
    
    
//    func transformWithRenderSchemeInPlace(schemeName: String){
//        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return}
//        guard let transformer = IntensityTransformers(rawValue: schemeName)?.transformer
//            else {fatalError("transformWithRenderSchemeInPlace received unknown schemeName parameter: \(schemeName)")}
//        transformer.transformWithSchemeInPlace(targetIAString: self)
//    }
    
    ///This will set max displayed bounds to all attached images, maintaining aspect fit. This function is necessary when reconstituting an IATextAttachment which has been archived (e.g. in a copy and paste).
//    func applyStoredImageConstraints(maxDisplayedSize mdSize:CGSize){
//        self.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location: 0, length: self.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (anyAttach, enumRange, stop) -> Void in
//            if let attachment = anyAttach as? IATextAttachment{
//                if let iaAttachSize = self.attribute(IATags.IAAttachmentSize, atIndex: enumRange.location, effectiveRange: nil) as? [String:AnyObject]{
//                    if let imageWidth = iaAttachSize["w"] as? CGFloat, imageHeight = iaAttachSize["h"] as? CGFloat {
//                        let newSize = CGSize(width: imageWidth, height: imageHeight).sizeThatFitsMaintainingAspect(containerSize: mdSize)
//                        attachment.bounds = CGRect(origin: CGPointZero, size: newSize)
//                    }
//                }
//            }
//        }
//    }
}



public extension NSAttributedString {
//    ///verifies that every element in string has IAIntensity and IASize.
//    func isFullyIntensityAttributed(checkMatchingScheme:Bool = false)->Bool{
//        for i in 0..<self.length {
//            let atts = self.attributesAtIndex(i, effectiveRange: nil)
//            guard atts[IATags.IAKeys] != nil else {return false }//atts.keys.contains(IATags.IAIntensity) && atts.keys.contains(IATags.IASize) else {return false}
//        }
//        return true
//    }
//    
//    ///Returns an array of NSRanges of text in self which is not IAAttributed
//    func getNonIARanges()->[NSRange]{
//        var nonIAIndices:[Int] = []
//        for i in 0..<self.length {
//            let atts = self.attributesAtIndex(i, effectiveRange: nil)
//            if atts[IATags.IAKeys] == nil {
//                nonIAIndices.append(i)
//            }
//        }
//        var nonIARanges:[NSRange] = []
//        while nonIAIndices.count > 0 {
//            let firstIndex = nonIAIndices.first!
//            var newRange:NSRange?
//            for (k, index) in nonIAIndices.enumerate(){
//                //if we've found a non-consecutive entry then we consider the range to have ended with length = prior value of k
//                if index - k != firstIndex {
//                    newRange = NSRange(location: firstIndex, length: k)
//                    break
//                }
//            }
//            if newRange == nil { //this means this was the last range that needs to be found
//                newRange = NSRange(location: firstIndex, length: nonIAIndices.count)
//            }
//            nonIARanges.append(newRange!)
//            nonIAIndices.removeRange(0..<(newRange!.length))
//        }
//        return nonIARanges
//    }
//    
//    ///Returns the average intensity value for a range of IA text. Returns 0.0 if an IAIntensity value is not found
//    func averageIntensityForRange(range:NSRange)->Float{
//        var intensities:[Float] = []
//        for i in (range.location)..<(range.location + range.length){
//            guard let iaAtts = self.attribute(IATags.IAKeys, atIndex: i, effectiveRange: nil) as? [String:AnyObject] else {return 0}
//            guard let thisIntensity = iaAtts[IATags.IAIntensity] as? Float else {return 0}
//            intensities.append(thisIntensity)
//        }
//        return intensities.reduce(0.0, combine: +) / Float(intensities.count)
//    }
//    
//    //transform
//    func transformWithRenderScheme(schemeName:String)->NSAttributedString!{
//        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return nil}
//        guard let transformer = IntensityTransformers(rawValue: schemeName)?.transformer
//            else {fatalError("transformWithRenderScheme received unknown schemeName parameter: \(schemeName)")}
//        return transformer.transformWithScheme(targetIAString: self)
//    }
//    
//    func transformWithRenderScheme(scheme:IntensityTransformers)->NSAttributedString!{
//        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return nil}
//        return scheme.transformer.transformWithScheme(targetIAString: self)
//    }
    
    
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
    convenience init(image:UIImage, intensityAttributes:IntensityAttributes, thumbSize:ThumbSize = .Medium, scaleToMaxSize:CGSize) {
            let attachment = IATextAttachment()
            attachment.image = image.resizeImageToFit(maxSize: scaleToMaxSize)
            attachment.thumbSize = thumbSize
            let imageSize = attachment.image!.size
            var iaAttributes = intensityAttributes.asAttributeDict
            iaAttributes[IATags.IAAttachmentSize] = ["w":imageSize.width,"h":imageSize.height]
            let attributes = [NSAttachmentAttributeName:attachment, IATags.IAKeys: iaAttributes]
            self.init(string: "\u{FFFC}", attributes: attributes)
    }
    
    ///Converts the NSAttributedString to an HTML approximation using the internal TextKit methods. Attachments are removed/ignored by the converter but their attachment characters (uFFFC) are replaced with substitution characters (uFFFD) so that attachment links can eventually be embedded in the HTML in their places. This second replacement is defered since a permanent URL for the resource may not yet exist. If the existing attributed string contains any substitution characters in its original form then all attachments will be discarded/ignored.
    func convertToHTMLApproximation()->String?{
        let temp = NSMutableAttributedString(attributedString: self)
        //We need to replace the existing attachment characters (uFFFC, which are discarded by by the Cocoa html generator) with the substitute character (uFFFD) which will remain and can be replaced with links to resources later in the process.
        let attachChar = "\u{FFFC}"
        let substituteChar = "\u{FFFD}"
        //we don't bother replacing chars if there are no attachment characters to replace or if there are substitute characters present for some reason.
        if temp.string.rangeOfString(substituteChar) == nil {
            while let attachCharRange = (temp.string as NSString).rangeOfString(attachChar) as NSRange? where attachCharRange.location != NSNotFound{
                temp.replaceCharactersInRange(attachCharRange, withString: substituteChar)
            }
        }
        guard let rawHTMLData = try? temp.dataFromRange(NSMakeRange(0, temp.length), documentAttributes: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]) else {return nil}
        return String(data: rawHTMLData, encoding: NSUTF8StringEncoding)
    }
    
//    func setMaxSizeForAllAttachments(maxSize:CGSize){
//        self.enumerateAttribute(IATags.IAAttachmentSize, inRange: NSRange(location:0, length:self.length), options: []) { (sizeObject, thisRange, stop) -> Void in
//            if let thisWidth = (sizeObject as? [String:AnyObject])?["w"] as? CGFloat, thisHeight = (sizeObject as? [String:AnyObject])?["h"] as? CGFloat {
//                if let thisAttachment = self.attribute(NSAttachmentAttributeName, atIndex: thisRange.location, effectiveRange: nil) as? IATextAttachment{
//                    let fittedSize = CGSizeMake(thisWidth, thisHeight).sizeThatFitsMaintainingAspect(containerSize: maxSize)
//                    thisAttachment.bounds = CGRect(origin: CGPointZero, size: fittedSize)
//                }
//                
//            }
//        }
//        
//    }
    //TODO: It may make more sense to perform this as an option directly in IAString's conversion to nsAttributedString. It may be desirable to cache NSAttString by its options (including thumb size) with separate copies made of each.
    func setThumbSizesForAttachments(thumbSize:ThumbSize){
        self.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location:0, length:self.length), options: []) { (attach, thisRange, stop) -> Void in
            if let attach = attach as? IATextAttachment{
                attach.thumbSize = thumbSize
            }
        }
    }
    
}
