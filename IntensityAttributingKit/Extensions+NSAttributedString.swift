import UIKit


public extension NSMutableAttributedString {
    ///Strips nonIA attributes (other than attachments and links), then applies IAAttributes of the supplied IntensityAttributes
    func applyIntensityAttributes(attributes:IntensityAttributes, toRange:NSRange! = nil, onlyToUnattributed:Bool = false){
        let range = toRange ?? NSRange(location: 0, length: self.length)
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
    
    ///This will set max displayed bounds to all attached images, maintaining aspect fit. This function is necessary when reconstituting an NSTextAttachment which has been archived (e.g. in a copy and paste).
    func applyStoredImageConstraints(maxDisplayedSize mdSize:CGSize){
        self.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location: 0, length: self.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (anyAttach, enumRange, stop) -> Void in
            if let attachment = anyAttach as? NSTextAttachment{
                if let iaAttachSize = self.attribute(IATags.IAAttachmentSize, atIndex: enumRange.location, effectiveRange: nil) as? [String:AnyObject]{
                    if let imageWidth = iaAttachSize["w"] as? CGFloat, imageHeight = iaAttachSize["h"] as? CGFloat {
                        let newSize = CGSize(width: imageWidth, height: imageHeight).sizeThatFitsMaintainingAspect(containerSize: mdSize)
                        attachment.bounds = CGRect(origin: CGPointZero, size: newSize)
                    }
                }
            }
        }
    }
}



public extension NSAttributedString {
    ///verifies that every element in string has IAIntensity and IASize.
    func isFullyIntensityAttributed(checkMatchingScheme:Bool = false)->Bool{
        for i in 0..<self.length {
            let atts = self.attributesAtIndex(i, effectiveRange: nil)
            guard atts[IATags.IAKeys] != nil else {return false }//atts.keys.contains(IATags.IAIntensity) && atts.keys.contains(IATags.IASize) else {return false}
        }
        return true
    }
    
    ///Returns an array of NSRanges of text in self which is not IAAttributed
    func getNonIARanges()->[NSRange]{
        var nonIAIndices:[Int] = []
        for i in 0..<self.length {
            let atts = self.attributesAtIndex(i, effectiveRange: nil)
            if atts[IATags.IAKeys] == nil {
                nonIAIndices.append(i)
            }
        }
        var nonIARanges:[NSRange] = []
        while nonIAIndices.count > 0 {
            let firstIndex = nonIAIndices.first!
            var newRange:NSRange?
            for (k, index) in nonIAIndices.enumerate(){
                //if we've found a non-consecutive entry then we consider the range to have ended with length = prior value of k
                if index - k != firstIndex {
                    newRange = NSRange(location: firstIndex, length: k)
                    break
                }
            }
            if newRange == nil { //this means this was the last range that needs to be found
                newRange = NSRange(location: firstIndex, length: nonIAIndices.count)
            }
            nonIARanges.append(newRange!)
            nonIAIndices.removeRange(0..<(newRange!.length))
        }
        return nonIARanges
    }
    
    ///Returns the average intensity value for a range of IA text. Returns 0.0 if an IAIntensity value is not found
    func averageIntensityForRange(range:NSRange)->Float{
        var intensities:[Float] = []
        for i in (range.location)..<(range.location + range.length){
            guard let iaAtts = self.attribute(IATags.IAKeys, atIndex: i, effectiveRange: nil) as? [String:AnyObject] else {return 0}
            guard let thisIntensity = iaAtts[IATags.IAIntensity] as? Float else {return 0}
            intensities.append(thisIntensity)
        }
        return intensities.reduce(0.0, combine: +) / Float(intensities.count)
    }
    
    //transform
    func transformWithRenderScheme(schemeName:String)->NSAttributedString!{
        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return nil}
        guard let transformer = IntensityTransformers(rawValue: schemeName)?.transformer
            else {fatalError("transformWithRenderScheme received unknown schemeName parameter: \(schemeName)")}
        return transformer.transformWithScheme(targetIAString: self)
    }
    
    func transformWithRenderScheme(scheme:IntensityTransformers)->NSAttributedString!{
        guard self.isFullyIntensityAttributed() else {print("transformWithRenderScheme: data not fully IA");return nil}
        return scheme.transformer.transformWithScheme(targetIAString: self)
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
    convenience init(image:UIImage, intensityAttributes:IntensityAttributes, displayMaxSize:CGSize, scaleToMaxSize:CGSize) {
            let attachment = NSTextAttachment()
            attachment.image = image.resizeImageToFit(maxSize: scaleToMaxSize)
            let imageSize = attachment.image!.size
            let displaySize = image.size.sizeThatFitsMaintainingAspect(containerSize: displayMaxSize)
            attachment.bounds = CGRect(origin: CGPointZero, size: displaySize)
            var iaAttributes = intensityAttributes.asAttributeDict
            iaAttributes[IATags.IAAttachmentSize] = ["w":imageSize.width,"h":imageSize.height]
            let attributes = [NSAttachmentAttributeName:attachment, IATags.IAKeys: iaAttributes]
            self.init(string: "\u{FFFC}", attributes: attributes)
    }
    
    
    func convertToHTMLApproximationWithScheme(scheme:IntensityTransformers)->String?{
        guard let rawHTMLData = try? self.dataFromRange(NSMakeRange(0, self.length), documentAttributes: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]) else {return nil}
            return String(data: rawHTMLData, encoding: NSUTF8StringEncoding)
    }
    
    func setMaxSizeForAllAttachments(maxSize:CGSize){
        self.enumerateAttribute(IATags.IAAttachmentSize, inRange: NSRange(location:0, length:self.length), options: []) { (sizeObject, thisRange, stop) -> Void in
            if let thisWidth = (sizeObject as? [String:AnyObject])?["w"] as? CGFloat, thisHeight = (sizeObject as? [String:AnyObject])?["h"] as? CGFloat {
                if let thisAttachment = self.attribute(NSAttachmentAttributeName, atIndex: thisRange.location, effectiveRange: nil) as? NSTextAttachment{
                    let fittedSize = CGSizeMake(thisWidth, thisHeight).sizeThatFitsMaintainingAspect(containerSize: maxSize)
                    thisAttachment.bounds = CGRect(origin: CGPointZero, size: fittedSize)
                }
                
            }
        }
        
    }
    
}
