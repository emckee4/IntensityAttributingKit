//
//  IATextAttachment.swift
//  IntensityAttributingKit
//
//  Created by Evan Mckee on 1/6/16.
//  Copyright © 2016 McKeeMaKer. All rights reserved.
//

import UIKit

/**
IATextAttachment is a subclass of NSTextAttachment providing thumbnails of various sizes for files which are cached in the cases of files with names (via the NSFileWrapper).
*/
public class IATextAttachment:NSTextAttachment {
    

    ///Either filename or random alpha string (if no filename exists) used for identifying attachments and images with or without filenames
    public lazy var localID:String = {return self.filename ?? String.randomAlphaString(8)}()
    
    public var isPlaceholder:Bool {
        return self.fileWrapper == nil && self.contents == nil && self.image == nil
    }
    
    
    public var filename:String?
    public var remoteFileURL:NSURL?
    public var localFileURL:NSURL?

    
    public var thumbSize: ThumbSize = .Medium
    
    private static let thumbCache = NSCache()
    public static let placeholderImage = UIImage(named: "imagePlaceholder", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: nil)!
    
    
//    var filewrapper:NSFileWrapper? {
//        didSet{
//            ///could load image in background and generate thumbs
//            _storedImageSize = nil
//        }
//    }
    

    
    
    private var wrappedFileName:String? {return self.fileWrapper?.preferredFilename}
    
    override public var image:UIImage? {
        get{
            if let supImage = super.image {
                return supImage
            } else {
                return wrappedImage
            }
        }
        set{
            super.image = newValue
            _storedContentSize = super.image?.size
        }
    }
    
    private var wrappedImage:UIImage? {
        let wrappedName:String? = wrappedFileName != nil ? wrappedFileName! + "-full" : nil
        if wrappedName != nil {
            if let cached = IATextAttachment.thumbCache.objectForKey(wrappedName!) as? UIImage{
                return cached
            }
        }
        if let wrappedData = self.fileWrapper?.regularFileContents {
            if let newImage = UIImage(data: wrappedData) {
                if wrappedName != nil {
                    IATextAttachment.thumbCache.setObject(newImage, forKey: wrappedName!)
                }
                return newImage
            }
        }
        return nil
    }
    
    ///saves the value so it doesn't need to be repeatedly recalculated
    private var _storedContentSize:CGSize?
    var storedContentSize:CGSize? {
        if let existing = _storedContentSize {
            return existing
        } else if let size = wrappedImage?.size {
            _storedContentSize = size
            return size
        } else if let size = self.image?.size {
            _storedContentSize = size
            return size
        }
        return nil
    }
    
    ///Yields the attachment data by trying first the filewrapper, then the contents, and finally the image property
    public var underlyingData:NSData? {
        if let wrappedData = self.fileWrapper?.regularFileContents {
            return wrappedData
        } else if let imageData = self.contents {
            return imageData
        } else if image != nil {
            return UIImageJPEGRepresentation(image!, 1.0)
        }
        return nil
    }
    
    
    override public func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        guard !isPlaceholder else {return self.placeholderForThumbSize(thumbSize)}
        guard let newSize = storedContentSize?.sizeThatFitsMaintainingAspect(containerSize:imageBounds.size ) else {print("IATextAttachment: imageForBounds: no base size found");return nil}
        var cachedThumbName:String? = nil
        if  filename != nil {
            cachedThumbName = filename! + thumbSize.rawValue
        } else {
            cachedThumbName = localID + thumbSize.rawValue
        }
        if cachedThumbName != nil {
            if let cachedThumb = IATextAttachment.thumbCache.objectForKey(cachedThumbName!) as? UIImage{
                return cachedThumb
            }
        }
        if let newThumb = self.wrappedImage?.resizeImageToFit(maxSize: newSize) {
            if cachedThumbName != nil {
                IATextAttachment.thumbCache.setObject(newThumb, forKey: cachedThumbName!)
            }
            return newThumb
        }
        
        if let newThumb = self.image?.resizeImageToFit(maxSize: newSize) {
            if cachedThumbName != nil {
                IATextAttachment.thumbCache.setObject(newThumb, forKey: cachedThumbName!)
            }
            return newThumb
        }
        return super.imageForBounds(imageBounds, textContainer: textContainer, characterIndex: charIndex)
    }
    
    override public func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        guard !isPlaceholder else {
            let phThumb = self.placeholderForThumbSize(self.thumbSize)
            let adjustedSize = phThumb.size.sizeThatFitsMaintainingAspect(containerSize: lineFrag.size)
            return CGRect(origin: lineFrag.origin, size: adjustedSize)
        }
//        return CGRectMake(0, 0, 150, 150)
        //let maxThumbSize = IAKitOptions.singleton.maxThumbnailSize
        let maxThumbSize = self.thumbSize.size
        
        let newThumbSize = storedContentSize?.sizeThatFitsMaintainingAspect(containerSize: maxThumbSize)
        if let newThumbSize = newThumbSize {return CGRect(origin: CGPointZero, size: newThumbSize)}
//        if let newSize = thumbSize?.sizeThatFitsMaintainingAspect(containerSize: lineFrag.size) {
//            return CGRect(origin: CGPointZero, size: newSize)
//        }
        return super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    }
    
/*
    public init(localIdentifier:String) {
        super.init(data: nil, ofType: nil)
        self.localID = localIdentifier
        usePlaceholderImage()
    }
*/
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let localID = aDecoder.decodeObjectForKey("localID") as? String {
            self.localID = localID
        }

        if let height = aDecoder.decodeObjectForKey("storedHeight") as? Float, width = aDecoder.decodeObjectForKey("storedWidth") as? Float{
            self._storedContentSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        if let fn = aDecoder.decodeObjectForKey("filename") as? String {self.filename = fn}
        if let localURL = aDecoder.decodeObjectForKey("localURL") as? NSURL {self.localFileURL = localURL}
        if let remoteURL = aDecoder.decodeObjectForKey("remoteURL") as? NSURL {self.remoteFileURL = remoteURL}
        
        
        if self.isPlaceholder {
            self.attemptToRealizeFileWrapper()
        }
        
    }
   
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)

        aCoder.encodeObject(localID, forKey: "localID")
        aCoder.encodeBool(self.isPlaceholder, forKey: "isPlaceholder")
        if let siSize = self._storedContentSize {
            
            aCoder.encodeFloat(Float(siSize.height), forKey: "storedHeight")
            aCoder.encodeFloat(Float(siSize.width), forKey: "storedWidth")
        }
        aCoder.encodeObject(self.filename, forKey: "filename")
        aCoder.encodeObject(self.remoteFileURL, forKey: "remoteURL")
        aCoder.encodeObject(self.localFileURL, forKey: "localFileURL")
        
    }
    
    
    override init(data contentData: NSData?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        
    }
    
    
    
//    public init(){
//        super.init(data: nil, ofType: nil)
//        usePlaceholderImage()
//    }
    
    ///Attempts to load filewrapper contents
    public func attemptToRealizeFileWrapper()->Bool{
//        if let localURL = self.localFileURL {
//            if let wrapper = try? NSFileWrapper(URL: localURL, options: []) {
//                self.fileWrapper = wrapper
//                return true
//            }
//        }
        return false
    }
    
    public init(filename:String,remoteURL:NSURL,localURL:NSURL?){
        super.init(data: nil, ofType: nil)
        self.filename = filename
        self.remoteFileURL = remoteURL
        self.localFileURL = localURL
        attemptToRealizeFileWrapper()
    }
    
    
        
}


///Thumbnail handling
extension IATextAttachment {

    
    func placeholderForThumbSize(thumbSize:ThumbSize)->UIImage{
        let cachedName = "imagePlaceholder-" + thumbSize.rawValue
        if let cachedThumb = IATextAttachment.thumbCache.objectForKey(cachedName) as? UIImage{
            return cachedThumb
        } else {
            let placeholderImage = UIImage(named: "imagePlaceholder", inBundle: IAKitOptions.bundle, compatibleWithTraitCollection: nil)!.resizeImageToFit(maxSize: thumbSize.size)
            IATextAttachment.thumbCache.setObject(placeholderImage, forKey: cachedName)
            return placeholderImage
        }
    }
    
//    func generateThumbnail(ofSize:ThumbSize)->UIImage!{
//        
//    }
//    
//    func getThumbnail(ofSize:ThumbSize)->UIImage!{
//        
//    }
    
    
    
}

extension IATextAttachment: CustomDebugStringConvertible{
    override public var debugDescription:String {
        return "<IATextAttachment>: filename: \(self.filename ?? "nil"), remoteFileURL:\(self.remoteFileURL ?? "nil"), localFileURL: \(self.localFileURL ?? "nil"), isPlaceholder:\(self.isPlaceholder)"
    }
}




public enum ThumbSize:String {
    case Tiny = "Tiny",
    Small = "Small",
    Medium = "Medium"
    
    var size: CGSize {
        switch self {
        case .Tiny: return CGSizeMake(30, 30)
        case .Small: return CGSizeMake(70, 70)
        case .Medium: return CGSizeMake(150, 150)
        }
    }
    
}





